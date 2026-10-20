function DP = component_engine_initialize_configuration(assembly_json, V, M, H)
%COMPONENT_ENGINE_INITIALIZE_CONFIGURATION Build the physical DP structure.
% A preset name is passed through the original INPUT_TURBO switch.  A JSON
% assembly uses the same DP-style fields and the extracted common head/tail.
% Design targets are applied by the following workflow stage.
runtime_root = fileparts(fileparts(mfilename('fullpath')));
old_directory = pwd;
old_path = path;
cleanup_directory = onCleanup(@() engine_restore_environment(old_directory, old_path)); %#ok<NASGU>
cd(runtime_root);
addpath(genpath(runtime_root), '-begin');

DP = struct();
DP.V = V;
DP.M = M;
DP.H = H;
DP.V_max = V;
DP.H_max = H;
DP.DT = 0;
DP.QP = 100;
DP.D = 0;

assembly = engine_decode_assembly(assembly_json);
if isfield(assembly, 'preset')
    DP.type = assembly.preset;
    DP = INPUT_TURBO(DP);
else
    if isfield(assembly, 'type')
        DP.type = assembly.type;
    end
    DP = INPUT_TURBO_CUSTOM(DP, assembly);
end
DP.display = 0;

% INPUT_DESIGN_PARAMETERS loads this same workbook even for configurations
% without a PMSM.  Keep the original field creation and ordering.
input_directory = fullfile(runtime_root, 'Input');
cd(input_directory);
pmsm_input = INPUT_ELECTRIC;
temp_variables = pmsm_input.thermal.temp_variables;
DP.temp_variables = temp_variables;
DP.NH = length(temp_variables);
DP.pmsm_input = pmsm_input;
if DP.NM1 > 0
    DP.pmsm_input(1:DP.NM1) = pmsm_input;
end
DP.temp_pmsm_ref = ones(DP.NH, DP.NM1);
DP.temp_pmsm = pmsm_input.temperature_limit * DP.temp_pmsm_ref;
cd(runtime_root);
DP.MAP = READMAP(DP);
end

function assembly = engine_decode_assembly(input_value)
if ischar(input_value) || isstring(input_value)
    text = char(input_value);
    trimmed = strtrim(text);
    if startsWith(trimmed, '{') || startsWith(trimmed, '[')
        assembly = jsondecode(text);
    else
        assembly = struct('preset', string(input_value));
    end
elseif isstruct(input_value)
    assembly = input_value;
else
    assembly = struct(input_value);
end
assembly = engine_decode_value(assembly);
if isstruct(assembly) && numel(assembly) == 1
    if isfield(assembly, 'schemaVersion') && ...
            strcmp(string(assembly.schemaVersion), "engine.physical-scene.v1")
        % EnginePhysicalSceneV1：后端只产出纯物理装配（nodes/edges/
        % relationGroups/assemblyDefaults）。发动机语义在此唯一推导。
        wrapper = struct();
        wrapper.templateDefinition = struct('rootSceneId', 'physical', ...
            'scenes', struct('physical', assembly));
        assembly = ENGINE_SCENE_ASSEMBLY(wrapper);
    elseif isfield(assembly, 'templateDefinition') && ...
            isstruct(assembly.templateDefinition)
        assembly = ENGINE_SCENE_ASSEMBLY(assembly);
    end
    assembly = engine_collect_instance_parameters(assembly);
end
end

function engine_restore_environment(old_directory, old_path)
cd(old_directory);
path(old_path);
end

function value = engine_decode_value(value)
if iscell(value)
    for k = 1:numel(value)
        value{k} = engine_decode_value(value{k});
    end
elseif isstruct(value)
    if isscalar(value) && isfield(value, 'value')
        payload = engine_decode_value(value.value);
        if isfield(value, 'type')
            payload = engine_cast_value(payload, value.type);
        end
        if isfield(value, 'shape')
            shape = double(value.shape(:)');
            payload = reshape(payload, shape);
        end
        value = payload;
    else
        names = fieldnames(value);
        for k = 1:numel(value)
            for n = 1:numel(names)
                value(k).(names{n}) = engine_decode_value(value(k).(names{n}));
            end
        end
    end
end
end

function value = engine_cast_value(value, type_value)
type_name = lower(char(type_value));
switch type_name
    case {'string','string_array'}
        value = string(value);
    case {'char','character'}
        value = char(value);
    case {'double','numeric'}
        value = double(value);
    case 'single'
        value = single(value);
    case {'logical','bool','boolean'}
        value = logical(value);
    case {'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
        value = feval(type_name, value);
    otherwise
        error('engine:UnsupportedAssemblyType', ...
            'Unsupported assembly value type: %s', type_name);
end
end

function assembly = engine_collect_instance_parameters(assembly)
list_name = '';
for candidate = {'components','component_instances','instances'}
    if isfield(assembly, candidate{1})
        list_name = candidate{1};
        break;
    end
end
if isempty(list_name) || ~isstruct(assembly.(list_name))
    return;
end
instances = assembly.(list_name);
if ~isfield(assembly, 'F')
    names = strings(1, numel(instances));
    for k = 1:numel(instances)
        if isfield(instances(k), 'type'), names(k) = string(instances(k).type); end
        if isfield(instances(k), 'name'), names(k) = string(instances(k).name); end
        if isfield(instances(k), 'componentType'), names(k) = string(instances(k).componentType); end
        if isfield(instances(k), 'component_type'), names(k) = string(instances(k).component_type); end
    end
    assembly.F = names;
end
parameter_names = {'TPR','WA_extraction','PRC','EFFC','EFFT','PRT', ...
    'EB','HU','TO','E_motor','E_mech','Q'};
for p = 1:numel(parameter_names)
    name = parameter_names{p};
    if isfield(assembly, name), continue; end
    present = false(1, numel(instances));
    values = cell(1, numel(instances));
    for k = 1:numel(instances)
        source = instances(k);
        if isfield(source, 'parameters') && isstruct(source.parameters) && ...
                isfield(source.parameters, name)
            values{k} = source.parameters.(name);
            present(k) = true;
        elseif isfield(source, name)
            values{k} = source.(name);
            present(k) = true;
        end
    end
    if any(present)
        ordered = values(present);
        try
            assembly.(name) = [ordered{:}];
        catch
            assembly.(name) = ordered{1};
        end
    end
end
global_names = {'PRC_outerfan','TPRM','BYPASS_RATIO','flow','reheat','SHAFT_CONTROL'};
for p = 1:numel(global_names)
    name = global_names{p};
    if isfield(assembly, name), continue; end
    for k = 1:numel(instances)
        source = instances(k);
        if isfield(source, 'parameters') && isstruct(source.parameters) && ...
                isfield(source.parameters, name)
            assembly.(name) = source.parameters.(name);
            break;
        elseif isfield(source, name)
            assembly.(name) = source.(name);
            break;
        end
    end
end
end
