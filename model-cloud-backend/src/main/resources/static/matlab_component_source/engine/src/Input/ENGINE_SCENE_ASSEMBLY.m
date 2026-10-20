function assembly = ENGINE_SCENE_ASSEMBLY(configuration)
%ENGINE_SCENE_ASSEMBLY Convert a backend physical scene to DP-style fields.
% Component values come from scene instances or explicit assemblyDefaults.
% Required fields on existing parts are reported together; absent turbine or
% combustor fields receive only the documented original ducted-fan defaults.
physical = configuration.templateDefinition.scenes.physical;
assembly = struct();
if isfield(physical, 'assemblyDefaults') && isstruct(physical.assemblyDefaults)
    names = fieldnames(physical.assemblyDefaults);
    for k = 1:numel(names)
        assembly.(names{k}) = physical.assemblyDefaults.(names{k});
    end
end
if ~isfield(assembly, 'type') && isfield(configuration, 'legacyName')
    assembly.type = configuration.legacyName;
end

nodes = engine_scene_normalize_records(physical.nodes);
component_mask = false(1, numel(nodes));
shaft_nodes = struct([]);
bleed_nodes = struct([]);
for k = 1:numel(nodes)
    if isfield(nodes(k), 'legacyName') && ~isempty(nodes(k).legacyName)
        component_mask(k) = true;
    elseif isfield(nodes(k), 'assemblyDefaults') && ...
            isfield(nodes(k).assemblyDefaults, 'connectorKind')
        kind = string(nodes(k).assemblyDefaults.connectorKind);
        if strcmpi(kind, 'shaft')
            shaft_nodes = [shaft_nodes, nodes(k)]; %#ok<AGROW>
        elseif strcmpi(kind, 'bleed')
            bleed_nodes = [bleed_nodes, nodes(k)]; %#ok<AGROW>
        end
    end
end
component_nodes = nodes(component_mask);
component_nodes = engine_scene_order_flow(component_nodes, physical);
shaft_nodes = engine_scene_order(shaft_nodes);
bleed_nodes = engine_scene_order(bleed_nodes);
relation_groups = struct([]);
if isfield(physical, 'relationGroups')
    relation_groups = engine_scene_normalize_records(physical.relationGroups);
    relation_groups = engine_scene_order_groups(relation_groups);
end
if ~isempty(relation_groups)
    shaft_nodes = relation_groups(strcmpi(string({relation_groups.relation}), 'shaft'));
    bleed_nodes = relation_groups(strcmpi(string({relation_groups.relation}), 'bleed'));
end
assembly.F = string({component_nodes.legacyName});
NF = numel(component_nodes);
assembly.NS = numel(shaft_nodes);
assembly.NW = numel(bleed_nodes);

assembly.TPR = engine_scene_component_vector(component_nodes, 'TPR');
assembly.WA_extraction = zeros(1, NF);
for k = 1:NF
    [found, value] = engine_scene_node_value(component_nodes(k), 'WA_extraction');
    if found, assembly.WA_extraction(k) = value; end
end
parameter_names = {'EFFC','EFFT','PRC','PRT','EB','HU','TO'};
missing_parameters = {};
for parameter = parameter_names
    name = parameter{1};
    indices = engine_scene_parameter_indices(assembly.F, name);
    missing_parameters = [missing_parameters, ...
        engine_scene_missing_parameter_records(component_nodes, indices, name)]; %#ok<AGROW>
    values = engine_scene_indexed_values(component_nodes, indices, name);
    if ~isempty(values)
        % Keep any additional legacy entries that are not represented by a
        % one-to-one gas-path component (for example the extra fan-stage
        % efficiency entry in the original mixed-turbofan configuration).
        % Mapped component values still replace their corresponding prefix.
        if isfield(assembly, name) && isnumeric(assembly.(name)) && ...
                isscalar(assembly.(name)) && all(values == assembly.(name))
            % Preserve legacy scalar semantics when the per-component values
            % merely repeat the same configured scalar.
        elseif isfield(assembly, name) && isnumeric(assembly.(name)) && ...
                isvector(assembly.(name)) && numel(assembly.(name)) >= numel(values)
            configured = assembly.(name);
            configured(1:numel(values)) = values;
            if isvector(configured)
                configured = reshape(configured, 1, []);
            end
            assembly.(name) = configured;
        else
            assembly.(name) = values;
        end
    end
end
if ~isempty(missing_parameters)
    error('engine:MissingAssemblyParameters', ...
        'Engine assembly is missing required component parameters: %s', ...
        strjoin(missing_parameters, '; '));
end
% The original ducted-fan branch initializes these fields even though the
% corresponding turbine/combustor components do not exist. Keep that DP
% shape for hand-built configurations while preserving explicit values.
if ~any(ismember(lower(assembly.F), ["hpt", "ipt", "lpt"]))
    if ~isfield(assembly, 'PRT'), assembly.PRT = 0; end
    if ~isfield(assembly, 'EFFT'), assembly.EFFT = 1; end
end
if ~any(ismember(lower(assembly.F), ["burn", "afterburn"]))
    if ~isfield(assembly, 'EB'), assembly.EB = 1; end
    if ~isfield(assembly, 'HU'), assembly.HU = 1; end
    if ~isfield(assembly, 'TO'), assembly.TO = 1; end
end
% jsondecode represents JSON vectors as columns. These DP fields follow the
% row-vector convention used by INPUT_TURBO even when their values came only
% from assemblyDefaults and no per-component override was available.
for parameter = {'EFFC','EFFT','PRC','PRT','EB','HU','TO'}
    name = parameter{1};
    if isfield(assembly, name) && isnumeric(assembly.(name)) && ...
            isvector(assembly.(name))
        assembly.(name) = reshape(assembly.(name), 1, []);
    end
end

% Relation groups describe shaft and bleed membership without canvas nodes.
assembly.SHAFT = zeros(max(1, assembly.NS), NF);
% INPUT_TURBO keeps a 1-by-NF zero EXT row even for configurations with
% NW == 0 (for example, the ducted fan). Preserve that legacy shape while
% retaining every explicitly declared bleed group, including empty groups.
assembly.EXT = zeros(max(1, assembly.NW), NF);
if isfield(physical, 'edges')
    edges = engine_scene_normalize_records(physical.edges);
else
    edges = struct([]);
end
if ~isempty(relation_groups)
    for row = 1:numel(shaft_nodes)
        members = engine_scene_group_members(shaft_nodes(row), edges, 'shaft');
        for member = members
            component_index = engine_scene_node_index(component_nodes, member);
            if component_index > 0, assembly.SHAFT(row, component_index) = 1; end
        end
    end
    for row = 1:numel(bleed_nodes)
        members = engine_scene_group_members(bleed_nodes(row), edges, 'bleed');
        for member = members
            component_index = engine_scene_node_index(component_nodes, member);
            if component_index > 0, assembly.EXT(row, component_index) = 1; end
        end
    end
    assembly = engine_scene_set_axis_parameters(assembly, shaft_nodes);
else
    for k = 1:numel(edges)
        if ~isfield(edges(k), 'relation') || ~isfield(edges(k), 'source') || ...
                ~isfield(edges(k), 'target')
            continue;
        end
        relation = string(edges(k).relation);
        target_index = engine_scene_node_index(component_nodes, edges(k).target);
        if target_index == 0, continue; end
        if strcmpi(relation, 'shaft')
            source_index = engine_scene_node_index(shaft_nodes, edges(k).source);
            if source_index > 0, assembly.SHAFT(source_index, target_index) = 1; end
        elseif strcmpi(relation, 'bleed')
            source_index = engine_scene_node_index(bleed_nodes, edges(k).source);
            if source_index > 0, assembly.EXT(source_index, target_index) = 1; end
        end
    end
end

[found, value] = engine_scene_first_node_value(shaft_nodes, 'E_mech');
if found && ~isfield(assembly, 'E_mech'), assembly.E_mech = value; end
[found, value] = engine_scene_first_node_value(shaft_nodes, 'E_motor');
if found && ~isfield(assembly, 'E_motor'), assembly.E_motor = value; end
axis_parameter_errors = {};
if assembly.NS == 0
    axis_parameter_errors{end + 1} = ...
        'No shaft groups are defined; create a shaft group and configure its mechanical efficiency'; %#ok<AGROW>
else
    % Do not reshape or truncate an explicitly stored legacy scalar/vector:
    % INPUT_TURBO contains historical configurations whose E_mech vector
    % length does not equal NS. New per-group scalar values are assembled in
    % the sorted group order by engine_scene_set_axis_parameters above.
    for name = {'E_mech', 'E_motor'}
        field = name{1};
        if ~isfield(assembly, field) || isempty(assembly.(field))
            group_labels = engine_scene_group_labels(shaft_nodes);
            axis_parameter_errors{end + 1} = sprintf('%s: missing for shaft groups %s', ...
                field, strjoin(group_labels, ', ')); %#ok<AGROW>
        end
    end
end

if ~isempty(axis_parameter_errors)
    error('engine:MissingAssemblyParameters', ...
        'Engine assembly has incomplete shaft parameters: %s', strjoin(axis_parameter_errors, '; '));
end
[found, value] = engine_scene_first_node_value(component_nodes, 'TPRM');
if ~found, [found, value] = engine_scene_first_node_value(shaft_nodes, 'TPRM'); end
if found, assembly.TPRM = value; end
[found, value] = engine_scene_first_node_value(component_nodes, 'PRC_outerfan');
if found, assembly.PRC_outerfan = value; end
[found, value] = engine_scene_first_node_value(component_nodes, 'BYPASS_RATIO');
if found, assembly.BYPASS_RATIO = value; end
[found, value] = engine_scene_first_node_value(component_nodes, 'flow');
if found, assembly.flow = value; end
[found, value] = engine_scene_first_node_value(component_nodes, 'reheat');
if found, assembly.reheat = value; end

% Detailed motors are gas-path members; their shaft coupling is a separate
% control/load binding and must not add a second mechanical SHAFT term.
motors=find(strcmpi(assembly.F,'hpcgv pmsm'));
if ~isempty(motors)
    if ~isfield(physical,'motorBindings')
        error('engine:MissingMotorBinding','Detailed PMSM requires an explicit shaft binding.');
    end
    bindings=engine_scene_normalize_records(physical.motorBindings);
    assembly.SHAFT_CONTROL=zeros(1,assembly.NS);
    assembly.motorProgramIds=strings(1,numel(motors));
    for index=1:numel(motors)
        node=component_nodes(motors(index));
        binding=find(strcmp(string({bindings.motorNodeId}),string(node.id)));
        if numel(binding)~=1, error('engine:MissingMotorBinding','PMSM %s must bind to one shaft.',node.id); end
        shaft=find(strcmp(string({shaft_nodes.id}),string(bindings(binding).shaftGroupId)));
        if numel(shaft)~=1||assembly.SHAFT_CONTROL(shaft)~=0
            error('engine:InvalidMotorBinding','PMSM shaft binding is missing or duplicated.');
        end
        assembly.SHAFT_CONTROL(shaft)=index;
        [found,program]=engine_scene_node_value(node,'program_id');
        if ~found||strlength(string(program))==0
            error('engine:MissingMotorProgram','PMSM %s has no compiled program.',node.id);
        end
        assembly.motorProgramIds(index)=string(program);
    end
end

% A backend typed DP payload may accompany the scene. It takes precedence
% while retaining its decoded type and shape metadata.
for container = {'DP','assembly','fields'}
    container_name = container{1};
    if isfield(configuration, container_name) && isstruct(configuration.(container_name))
        names = fieldnames(configuration.(container_name));
        for k = 1:numel(names)
            assembly.(names{k}) = configuration.(container_name).(names{k});
        end
    end
end
end

function labels = engine_scene_group_labels(groups)
labels = strings(1, numel(groups));
for k = 1:numel(groups)
    if isfield(groups(k), 'name') && ~isempty(groups(k).name)
        labels(k) = string(groups(k).name);
    elseif isfield(groups(k), 'id')
        labels(k) = string(groups(k).id);
    else
        labels(k) = "轴组 " + k;
    end
end
end

function groups = engine_scene_order_groups(groups)
if isempty(groups), return; end
order = zeros(1, numel(groups));
for k = 1:numel(groups)
    if isfield(groups(k), 'order') && ~isempty(groups(k).order)
        order(k) = double(groups(k).order);
    else
        order(k) = k;
    end
end
[~, indices] = sort(order);
groups = groups(indices);
end

function members = engine_scene_group_members(group, edges, relation)
members = string(group.anchorNodeId);
if members == "", members = strings(1, 0); end
for k = 1:numel(edges)
    if ~isfield(edges(k), 'relation') || ~strcmpi(string(edges(k).relation), relation)
        continue;
    end
    group_id = "";
    if isfield(edges(k), 'groupId'), group_id = string(edges(k).groupId); end
    if group_id == "" && isfield(edges(k), 'data') && isstruct(edges(k).data) && ...
            isfield(edges(k).data, 'groupId')
        group_id = string(edges(k).data.groupId);
    end
    if group_id ~= string(group.id), continue; end
    members(end+1) = string(edges(k).source); %#ok<AGROW>
    members(end+1) = string(edges(k).target); %#ok<AGROW>
end
members = unique(members, 'stable');
end

function assembly = engine_scene_set_axis_parameters(assembly, shaft_nodes)
parameter_names = {'E_mech', 'E_motor', 'SHAFT_CONTROL'};
for parameter_index = 1:numel(parameter_names)
    name = parameter_names{parameter_index};
    values = cell(1, numel(shaft_nodes));
    present = true(1, numel(shaft_nodes));
    for row = 1:numel(shaft_nodes)
        if isfield(shaft_nodes(row), 'parameters') && ...
                isfield(shaft_nodes(row).parameters, name)
            values{row} = shaft_nodes(row).parameters.(name);
        else
            present(row) = false;
        end
    end
    if isempty(values) || ~all(present), continue; end
    if numel(values) == 1
        assembly.(name) = values{1};
    elseif strcmp(name, 'E_motor') || strcmp(name, 'SHAFT_CONTROL')
        assembly.(name) = horzcat(values{:});
    else
        assembly.(name) = vertcat(values{:});
    end
end
end

function records = engine_scene_normalize_records(records)
if ~iscell(records), return; end
if isempty(records), records = struct([]); return; end
names = {};
for k = 1:numel(records)
    names = union(names, fieldnames(records{k}), 'stable');
end
template = struct();
for k = 1:numel(names), template.(names{k}) = []; end
normalized = repmat(template, 1, numel(records));
for k = 1:numel(records)
    fields = fieldnames(records{k});
    for n = 1:numel(fields)
        normalized(k).(fields{n}) = records{k}.(fields{n});
    end
end
records = normalized;
end

function nodes = engine_scene_order(nodes)
if isempty(nodes), return; end
order = zeros(1, numel(nodes));
for k = 1:numel(nodes)
    if isfield(nodes(k), 'legacyOrder')
        order(k) = double(nodes(k).legacyOrder);
    else
        order(k) = k;
    end
end
[~, index] = sort(order);
nodes = nodes(index);
end

function nodes = engine_scene_order_flow(nodes, physical)
% The flow graph, not canvas position or legacyOrder, defines DP.F.
if isempty(nodes), return; end
if ~isfield(physical, 'edges')
    error('engine:FlowTopology', 'Physical scene has no flow edges.');
end
edges = engine_scene_normalize_records(physical.edges);
ids = strings(1, numel(nodes));
for k = 1:numel(nodes), ids(k) = string(nodes(k).id); end
degree = zeros(1, numel(nodes));
successors = cell(1, numel(nodes));
priority = 2 * ones(1, numel(nodes));
flow_count = 0;
for k = 1:numel(edges)
    if ~isfield(edges(k), 'relation') || ~strcmpi(string(edges(k).relation), 'flow')
        continue;
    end
    flow_count = flow_count + 1;
    source = find(ids == string(edges(k).source), 1);
    target = find(ids == string(edges(k).target), 1);
    if isempty(source) || isempty(target) || source == target
        error('engine:FlowTopology', 'Invalid flow edge in physical scene.');
    end
    successors{source}(end + 1) = target; %#ok<AGROW>
    degree(target) = degree(target) + 1;
    if isfield(edges(k), 'data') && isstruct(edges(k).data) && ...
            isfield(edges(k).data, 'streamRole')
        role = string(edges(k).data.streamRole);
        if strcmpi(role, 'bypass'), priority(target) = min(priority(target), 0); end
        if strcmpi(role, 'core'), priority(target) = min(priority(target), 1); end
    end
end
if numel(nodes) > 1 && flow_count == 0
    error('engine:FlowTopology', 'Physical scene has no flow connections.');
end
legacy_order = 1:numel(nodes);
for k = 1:numel(nodes)
    if isfield(nodes(k), 'legacyOrder') && ~isempty(nodes(k).legacyOrder)
        legacy_order(k) = double(nodes(k).legacyOrder);
    end
end
ordered = zeros(1, numel(nodes));
used = false(1, numel(nodes));
for k = 1:numel(nodes)
    available = find(~used & degree == 0);
    if isempty(available)
        error('engine:FlowTopology', 'Flow graph cannot be linearized.');
    end
    [~, rank] = sortrows([priority(available)', legacy_order(available)', available'], [1 2 3]);
    current = available(rank(1));
    ordered(k) = current;
    used(current) = true;
    degree(successors{current}) = degree(successors{current}) - 1;
end
nodes = nodes(ordered);
end

function values = engine_scene_component_vector(nodes, name)
values = [];
if isempty(nodes), return; end
values = zeros(1, numel(nodes));
for k = 1:numel(nodes)
    [found, value] = engine_scene_node_value(nodes(k), name);
    if ~found, values = []; return; end
    values(k) = value;
end
end

function indices = engine_scene_parameter_indices(F, name)
switch name
    case {'EFFC','PRC'}
        indices = find(strcmpi(F, "fan") | strcmpi(F, "lpc") | ...
            strcmpi(F, "ipc") | strcmpi(F, "hpc"));
    case {'EFFT','PRT'}
        indices = find(strcmpi(F, "lpt") | ...
            strcmpi(F, "ipt") | strcmpi(F, "hpt"));
    case {'EB','HU','TO'}
        indices = find(strcmpi(F, "burn") | ...
            strcmpi(F, "afterburn"));
    otherwise
        indices = 1:numel(F);
end
end

function missing = engine_scene_missing_parameter_records(nodes, indices, name)
missing = {};
for index = indices
    [found, ~] = engine_scene_node_value(nodes(index), name);
    if found, continue; end
    instance_name = string(nodes(index).id);
    if isfield(nodes(index), 'instanceName') && ~isempty(nodes(index).instanceName)
        instance_name = string(nodes(index).instanceName);
    end
    missing{end + 1} = sprintf('%s: %s (id=%s)', name, instance_name, string(nodes(index).id)); %#ok<AGROW>
end
end

function values = engine_scene_indexed_values(nodes, indices, name)
values = [];
if isempty(indices), return; end
values = zeros(1, numel(indices));
for k = 1:numel(indices)
    [found, value] = engine_scene_node_value(nodes(indices(k)), name);
    if ~found, values = []; return; end
    values(k) = value;
end
end

function index = engine_scene_node_index(nodes, node_id)
index = 0;
if isempty(nodes), return; end
ids = strings(1, numel(nodes));
for k = 1:numel(nodes)
    if isfield(nodes(k), 'id'), ids(k) = string(nodes(k).id); end
end
match = find(ids == string(node_id), 1);
if ~isempty(match), index = match; end
end

function [found, value] = engine_scene_first_node_value(nodes, name)
found = false;
value = [];
for k = 1:numel(nodes)
    [found, value] = engine_scene_node_value(nodes(k), name);
    if found, return; end
end
end

function [found, value] = engine_scene_node_value(node, name)
found = false;
value = [];
% User-edited values/parameters override the component default payload.
for container = {'values','parameters','assemblyDefaults'}
    container_name = container{1};
    if isfield(node, container_name) && isstruct(node.(container_name)) && ...
            isfield(node.(container_name), name)
        found = true;
        value = node.(container_name).(name);
        return;
    end
end
end
