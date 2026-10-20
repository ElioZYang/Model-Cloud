function report = component_engine_backend_scene_tests(include_plot_regression, include_numerical_regression)
%COMPONENT_ENGINE_BACKEND_SCENE_TESTS Exercise the backend assembly shape.
% The fixtures mirror the three physical scenes in engine-components.json,
% including typed DP structural wrappers and direct relation groups.
% Plot regression can be disabled for a numerical-only run on hosts where
% MATLAB graphics initialization is unavailable (for example headless CI).
if nargin < 1, include_plot_regression = true; end
if nargin < 2, include_numerical_regression = true; end
configs = {'ducted fan','turboshaft','mixed turbofan'};
report = repmat(struct('configuration','', 'passed',false, ...
    'scan_points',0, 'scan_status','', 'file_count',0), 1, numel(configs));
old_directory = pwd;
old_path = path;
engine_assert_arbitrary_shaft_count();
engine_assert_hand_built_component_parameters();
engine_assert_power_requires_shaft();
if ~include_numerical_regression
    for k = 1:numel(configs)
        report(k).configuration = configs{k};
        report(k).passed = true;
        report(k).scan_status = 'structural_checks_only';
    end
    return;
end
for k = 1:numel(configs)
    configuration = configs{k};
    fixture = engine_backend_scene_fixture(configuration);
    if strcmp(configuration, 'mixed turbofan')
        engine_assert_raw_mixed_topology(fixture);
    end
    assembly_json = jsonencode(fixture);
    scene_dp = component_engine_initialize_configuration(assembly_json, 60, 0, 3000);
    preset_dp = component_engine_initialize_configuration(configuration, 60, 0, 3000);
    raw_fixture = rmfield(fixture, 'DP');
    raw_dp = component_engine_initialize_configuration(jsonencode(raw_fixture), 60, 0, 3000);
    assert(isequal(raw_dp.F, preset_dp.F));
    assert(isequal(raw_dp.SHAFT, preset_dp.SHAFT));
    assert(isequal(raw_dp.EXT, preset_dp.EXT));
    assert(isequal(raw_dp.WA_extraction, preset_dp.WA_extraction));
    assert(isequal(size(raw_dp.E_mech), size(preset_dp.E_mech)));
    assert(isequaln(raw_dp.E_mech, preset_dp.E_mech));
    assert(isequaln(raw_dp.E_motor, preset_dp.E_motor));
    assert(strcmp(path, old_path));
    assert(strcmp(pwd, old_directory));
    engine_assert_initialization_match(scene_dp, preset_dp);

    scene_dp = component_engine_apply_design_conditions(scene_dp, 0, 0, ...
        1000 * ones(scene_dp.NS, 1));
    preset_dp = component_engine_apply_design_conditions(preset_dp, 0, 0, ...
        1000 * ones(preset_dp.NS, 1));
    [scene_dp, scene_xd] = component_engine_solve_design_point(scene_dp);
    [preset_dp, preset_xd] = component_engine_solve_design_point(preset_dp);
    assert(strcmp(path, old_path));
    assert(strcmp(pwd, old_directory));
    engine_assert_numeric_match(scene_xd, preset_xd, 1e-8);
    engine_assert_numeric_match(scene_dp.YD, preset_dp.YD, 1e-8);
    engine_assert_initialization_match(scene_dp, preset_dp);

    scene_scan = engine_capture_envelope(scene_dp, 3, 4, 4);
    preset_scan = engine_capture_envelope(preset_dp, 3, 4, 4);
    assert(strcmp(path, old_path));
    assert(strcmp(pwd, old_directory));
    if scene_scan.completed
        assert(preset_scan.completed);
        engine_assert_numeric_match(scene_scan.THRUST, preset_scan.THRUST, 1e-8);
        engine_assert_numeric_match(scene_scan.TIT, preset_scan.TIT, 1e-8);
        engine_assert_numeric_match(scene_scan.COMP, preset_scan.COMP, 1e-8);
        engine_assert_numeric_match(scene_scan.TURB, preset_scan.TURB, 1e-8);
        engine_assert_numeric_match(scene_scan.MOTOR, preset_scan.MOTOR, 1e-8);
        engine_assert_numeric_match(scene_scan.OP.THRUST, preset_scan.OP.THRUST, 1e-8);
        engine_assert_numeric_match(scene_scan.X0, preset_scan.X0, 1e-8);
        engine_assert_numeric_match(scene_scan.DX, preset_scan.DX, 1e-8);
        assert(isequaln(scene_scan.MISSION.G.MAP, preset_scan.MISSION.G.MAP));
        assert(numel(scene_scan.THRUST) == 11);
        assert(numel(scene_scan.TIT) == 11);
        assert(isfield(scene_scan.MISSION, 'G'));
        assert(~isfield(scene_scan.MISSION.G, 'ENVELOPE'));
        assert(isequal(sort(fieldnames(scene_scan.MISSION.G)), ...
            sort({'DP', 'MAP', 'COMP_WP', 'TURB_WP', 'MOTOR_WP'}')));
        report(k).scan_points = numel(scene_scan.THRUST);
        report(k).scan_status = 'completed';
    else
        % The mixed-turbofan legacy mixer can throw at the first scan point;
        % both assembly forms must expose the same native exception.
        assert(~preset_scan.completed);
        assert(strcmp(scene_scan.identifier, preset_scan.identifier));
        assert(strcmp(scene_scan.message, preset_scan.message));
        report(k).scan_status = 'same_native_exception';
    end

    report(k).configuration = configuration;
    report(k).passed = true;

    if include_plot_regression && strcmp(configuration, 'turboshaft') && scene_scan.completed
        design_directory = tempname(tempdir);
        power_directory = tempname(tempdir);
        final_directory = tempname(tempdir);
        cleanup_output = onCleanup(@() engine_remove_outputs( ...
            {design_directory, power_directory, final_directory})); %#ok<NASGU>

        design_result = component_engine_plot_flow(scene_scan.MISSION.G.DP, ...
            design_directory, 'design');
        engine_assert_plot_manifest(design_result, 'design', 'PLOTFLOW');
        assert(isempty(findall(0, 'Type', 'figure')));

        stage_state = component_engine_envelope_initialize(scene_dp);
        [stage_state, mission_power] = component_engine_envelope_power(stage_state, 3);
        power_result = component_engine_plot_map_mission(mission_power, ...
            power_directory, 'power');
        engine_assert_plot_manifest(power_result, 'power', 'DRAW_MAP_MISSION');
        assert(isempty(findall(0, 'Type', 'figure')));
        stage_state = component_engine_envelope_speed_initialize(stage_state);
        stage_state = component_engine_envelope_speed(stage_state, 4);
        stage_state = component_engine_envelope_altitude(stage_state, 4);
        [stage_mission, stage_thrust, stage_tit, stage_comp, stage_turb, ...
            stage_motor] = component_engine_envelope_finalize(stage_state);
        assert(isequaln(stage_thrust, scene_scan.THRUST));
        assert(isequaln(stage_tit, scene_scan.TIT));
        assert(isequaln(stage_comp, scene_scan.COMP));
        assert(isequaln(stage_turb, scene_scan.TURB));
        assert(isequaln(stage_motor, scene_scan.MOTOR));

        final_result = component_engine_plot_map_mission(stage_mission, ...
            final_directory, 'final');
        engine_assert_plot_manifest(final_result, 'final', 'DRAW_MAP_MISSION');
        assert(isempty(findall(0, 'Type', 'figure')));
        report(k).file_count = numel(design_result.files) + ...
            numel(power_result.files) + numel(final_result.files);
        assert(strcmp(path, old_path));
        assert(strcmp(pwd, old_directory));
    end
end
end

function engine_assert_arbitrary_shaft_count()
% The assembly adapter must preserve arbitrary shaft counts, including
% shaft-specific parameter ordering, without a configuration-name branch.
fixture = engine_backend_scene_fixture('turboshaft');
fixture = rmfield(fixture, 'DP');
physical = fixture.templateDefinition.scenes.physical;
groups = physical.relationGroups;
groups(1).parameters.E_motor = 0.97;
second = engine_scene_group('shaft_2', 'shaft', 'hpt_1', 0.98);
second.order = 2;
second.parameters.E_motor = 0.96;
third = engine_scene_group('shaft_3', 'shaft', 'hpc_1', 0.97);
third.order = 3;
third.parameters.E_motor = 0.95;
physical.relationGroups = [groups, second, third];
fixture.templateDefinition.scenes.physical = physical;
assembly = ENGINE_SCENE_ASSEMBLY(fixture);
assert(assembly.NS == 3);
assert(isequal(size(assembly.SHAFT), [3 6]));
assert(isequal(assembly.E_mech, [0.985; 0.98; 0.97]));
assert(isequal(assembly.E_motor, [0.97 0.96 0.95]));
end

function engine_assert_hand_built_component_parameters()
% A compressor-only hand-built cycle needs the same legacy placeholder fields
% as the original ducted-fan branch, without pretending the compressor is a
% turbine or combustor.
fixture = engine_backend_scene_fixture('ducted fan');
fixture = rmfield(fixture, 'DP');
physical = fixture.templateDefinition.scenes.physical;
physical.assemblyDefaults = rmfield(physical.assemblyDefaults, 'type');
physical.nodes(2).assemblyDefaults = rmfield(physical.nodes(2).assemblyDefaults, ...
    {'EFFT','PRT','TO','EB','HU'});
fixture.templateDefinition.scenes.physical = physical;
assembly = ENGINE_SCENE_ASSEMBLY(fixture);
assert(isequal(assembly.F, ["inlet","lpc","nozzle"]));
assert(assembly.PRT == 0 && assembly.EFFT == 1);
assert(assembly.EB == 1 && assembly.HU == 1 && assembly.TO == 1);

% Placeholder fields are defaults only: explicit legacy values, including
% nonstandard values, remain untouched when the corresponding parts are absent.
physical.assemblyDefaults.PRT = -2;
physical.assemblyDefaults.EFFT = 0.42;
physical.assemblyDefaults.EB = 0;
physical.assemblyDefaults.HU = -3;
physical.assemblyDefaults.TO = 0;
fixture.templateDefinition.scenes.physical = physical;
assembly = ENGINE_SCENE_ASSEMBLY(fixture);
assert(assembly.PRT == -2 && assembly.EFFT == 0.42);
assert(assembly.EB == 0 && assembly.HU == -3 && assembly.TO == 0);

physical.relationGroups = physical.relationGroups(~strcmpi( ...
    {physical.relationGroups.relation}, 'shaft'));
fixture.templateDefinition.scenes.physical = physical;
try
    ENGINE_SCENE_ASSEMBLY(fixture);
    error('engine:TestExpectedMissingShaftGroup', 'Expected an explicit missing-shaft structure error.');
catch exception
    assert(strcmp(exception.identifier, 'engine:MissingAssemblyParameters'));
    assert(contains(exception.message, 'No shaft groups are defined'));
end

% Missing values on actual engine components are reported together with
% component identity instead of being hidden by the no-component defaults.
fixture = engine_backend_scene_fixture('turboshaft');
fixture = rmfield(fixture, 'DP');
physical = fixture.templateDefinition.scenes.physical;
physical.nodes(4).assemblyDefaults = rmfield(physical.nodes(4).assemblyDefaults, 'HU');
physical.nodes(5).assemblyDefaults = rmfield(physical.nodes(5).assemblyDefaults, {'EFFT','PRT'});
fixture.templateDefinition.scenes.physical = physical;
try
    ENGINE_SCENE_ASSEMBLY(fixture);
    error('engine:TestExpectedMissingParameters', 'Expected missing component parameter validation.');
catch exception
    assert(strcmp(exception.identifier, 'engine:MissingAssemblyParameters'));
    assert(contains(exception.message, 'HU: burn_1'));
    assert(contains(exception.message, 'EFFT: hpt_1'));
    assert(contains(exception.message, 'PRT: hpt_1'));
end
end

function engine_assert_power_requires_shaft()
try
    component_engine_apply_design_conditions(struct('NS',0), 0, 0, 1000);
    error('engine:TestExpectedMissingShaft', 'Expected nonzero power without a shaft group to fail.');
catch exception
    assert(strcmp(exception.identifier, 'engine:PowerRequiresShaftGroup'));
end
end

function engine_assert_raw_mixed_topology(fixture)
% Exercise ENGINE_SCENE_ASSEMBLY without the typed DP.F override.  The
% deliberately perturbed legacyOrder requires bypass priority to determine
% the fan branch order.
raw_fixture = rmfield(fixture, 'DP');
physical = raw_fixture.templateDefinition.scenes.physical;
nodes = physical.nodes;
nodes(4).legacyOrder = 50;  % outer duct must still precede the core branch
nodes(5).legacyOrder = 5;
physical.nodes = nodes([1 2 3 5 4 6 7 8 9 10]);
edges = physical.edges;
for k = 1:numel(edges)
    edges(k).data = struct('streamRole', '');
end
for k = 1:numel(edges)
    edge_id = string(edges(k).id);
    if startsWith(edge_id, 'flow_bypass')
        edges(k).data.streamRole = 'bypass';
    elseif startsWith(edge_id, 'flow_core')
        edges(k).data.streamRole = 'core';
    end
end
physical.edges = edges;
raw_fixture.templateDefinition.scenes.physical = physical;
raw_dp = component_engine_initialize_configuration(jsonencode(raw_fixture), 60, 0, 3000);
expected = ["inlet", "duct", "fan", "outer duct", "hpc", "burn", ...
    "hpt", "mixer", "afterburn", "nozzle"];
assert(isequal(raw_dp.F, expected));
end

function capture = engine_capture_envelope(DP, power_points, speed_points, altitude_points)
capture = struct('completed',false,'identifier','','message','', ...
    'MISSION',[],'THRUST',[],'TIT',[],'COMP',[],'TURB',[],'MOTOR',[], ...
    'OP',[],'X0',[],'DX',[]);
try
    [capture.MISSION, capture.THRUST, capture.TIT, capture.COMP, ...
        capture.TURB, capture.MOTOR, capture.OP, capture.X0, capture.DX] = ...
        component_run_engine_envelope(DP, power_points, speed_points, altitude_points);
    capture.completed = true;
catch exception
    capture.identifier = exception.identifier;
    capture.message = exception.message;
end
end

function fixture = engine_backend_scene_fixture(configuration)
switch configuration
    case 'ducted fan'
        nodes = [
            engine_scene_node('inlet_1','inlet',1,struct('TPR',-1)), ...
            engine_scene_node('lpc_1','lpc',2,struct('TPR',1,'EFFC',0.87,'PRC',1.1,'EFFT',1,'PRT',0,'TO',1,'EB',1,'HU',1)), ...
            engine_scene_node('nozzle_1','nozzle',3,struct('TPR',0.97))];
        edges = [engine_scene_edge('flow_1','inlet_1','OUTPUT','lpc_1','INPUT','flow'), ...
            engine_scene_edge('flow_2','lpc_1','OUTPUT','nozzle_1','INPUT','flow')];
        groups = engine_scene_group('shaft_1','shaft','lpc_1',0.985);
        F = ["inlet","lpc","nozzle"];
        shaft = [0 1 0]; ext = [0 0 0]; wa = [0 0 0];
        thrust = -1;
    case 'turboshaft'
        nodes = [
            engine_scene_node('inlet_1','inlet',1,struct('TPR',-1)), ...
            engine_scene_node('duct_1','duct',2,struct('TPR',0.97)), ...
            engine_scene_node('hpc_1','hpc',3,struct('TPR',1,'EFFC',0.85,'PRC',4,'WA_extraction',0)), ...
            engine_scene_node('burn_1','burn',4,struct('TPR',0.99,'EB',0.99,'HU',43124000,'TO',1450)), ...
            engine_scene_node('hpt_1','hpt',5,struct('TPR',1,'EFFT',0.89,'PRT',0,'WA_extraction',0)), ...
            engine_scene_node('nozzle_1','nozzle',6,struct('TPR',0.97))];
        edges = [engine_scene_edge('flow_1','inlet_1','OUTPUT','duct_1','INPUT','flow'), ...
            engine_scene_edge('flow_2','duct_1','OUTPUT','hpc_1','INPUT','flow'), ...
            engine_scene_edge('flow_3','hpc_1','OUTPUT','burn_1','INPUT','flow'), ...
            engine_scene_edge('flow_4','burn_1','OUTPUT','hpt_1','INPUT','flow'), ...
            engine_scene_edge('flow_5','hpt_1','OUTPUT','nozzle_1','INPUT','flow'), ...
            engine_scene_edge('shaft_hpt','hpc_1','SHAFT_OUT','hpt_1','SHAFT_IN','shaft','shaft_1'), ...
            engine_scene_edge('bleed_hpt','hpc_1','BLEED_OUT','hpt_1','BLEED_IN','bleed','bleed_1')];
        groups = [engine_scene_group('shaft_1','shaft','hpc_1',0.985), ...
            engine_scene_group('bleed_1','bleed','hpc_1',[])];
        F = ["inlet","duct","hpc","burn","hpt","nozzle"];
        shaft = [0 0 1 0 1 0]; ext = [0 0 1 0 1 0]; wa = zeros(1,6);
        thrust = 0;
    case 'mixed turbofan'
        nodes = [
            engine_scene_node('inlet_1','inlet',1,struct('TPR',-1)), ...
            engine_scene_node('duct_1','duct',2,struct('TPR',0.97)), ...
            engine_scene_node('fan_1','fan',3,struct('TPR',1,'EFFC',0.79,'PRC',1.5,'BYPASS_RATIO',0.25,'PRC_outerfan',1.6)), ...
            engine_scene_node('outer_duct_1','outer duct',4,struct('TPR',0.97)), ...
            engine_scene_node('hpc_1','hpc',5,struct('TPR',1,'EFFC',0.79,'PRC',7,'WA_extraction',0)), ...
            engine_scene_node('burn_1','burn',6,struct('TPR',0.99,'EB',0.99,'HU',43124000,'TO',1800)), ...
            engine_scene_node('hpt_1','hpt',7,struct('TPR',1,'EFFT',0.89,'PRT',0,'WA_extraction',0)), ...
            engine_scene_node('mixer_1','mixer',8,struct('TPR',1,'TPRM',0.8)), ...
            engine_scene_node('afterburn_1','afterburn',9,struct('TPR',0.9,'EB',0.99,'HU',43124000,'TO',2200,'reheat',0)), ...
            engine_scene_node('nozzle_1','nozzle',10,struct('TPR',0.97))];
        edges = [engine_scene_edge('flow_1','inlet_1','OUTPUT','duct_1','INPUT','flow'), ...
            engine_scene_edge('flow_2','duct_1','OUTPUT','fan_1','INPUT','flow'), ...
            engine_scene_edge('flow_bypass_1','fan_1','OUTPUT','outer_duct_1','INPUT','flow'), ...
            engine_scene_edge('flow_core_1','fan_1','OUTPUT','hpc_1','INPUT','flow'), ...
            engine_scene_edge('flow_core_2','hpc_1','OUTPUT','burn_1','INPUT','flow'), ...
            engine_scene_edge('flow_core_3','burn_1','OUTPUT','hpt_1','INPUT','flow'), ...
            engine_scene_edge('flow_core_4','hpt_1','OUTPUT','mixer_1','INPUT','flow'), ...
            engine_scene_edge('flow_bypass_2','outer_duct_1','OUTPUT','mixer_1','INPUT1','flow'), ...
            engine_scene_edge('flow_3','mixer_1','OUTPUT','afterburn_1','INPUT','flow'), ...
            engine_scene_edge('flow_4','afterburn_1','OUTPUT','nozzle_1','INPUT','flow'), ...
            engine_scene_edge('shaft_hpc','fan_1','SHAFT_OUT','hpc_1','SHAFT_IN','shaft','shaft_1'), ...
            engine_scene_edge('shaft_hpt','hpc_1','SHAFT_OUT','hpt_1','SHAFT_IN','shaft','shaft_1'), ...
            engine_scene_edge('bleed_hpt','hpc_1','BLEED_OUT','hpt_1','BLEED_IN','bleed','bleed_1')];
        groups = [engine_scene_group('shaft_1','shaft','fan_1', ...
            engine_typed([0.985;0.985],'double',[2 1])), ...
            engine_scene_group('bleed_1','bleed','hpc_1',[])];
        F = ["inlet","duct","fan","outer duct","hpc","burn","hpt","mixer","afterburn","nozzle"];
        shaft = [0 0 1 0 1 0 1 0 0 0]; ext = [0 0 0 0 1 0 1 0 0 0]; wa = zeros(1,10);
        thrust = 98;
    otherwise
        error('engine:TestConfiguration', 'Unknown test configuration.');
end
physical_defaults = struct('type',configuration, ...
    'THRUST',thrust,'WA',0,'E_motor',0.97);
% Match the actual preset defaults: ducted fan does not define TPRM, while
% the turboshaft preset does.  The mixed-turbofan TPRM comes from its mixer
% component instance, just as it does in the model-library template.
if strcmp(configuration, 'turboshaft')
    physical_defaults.TPRM = 0.5;
end
physical = struct('id','physical','parentSceneId','workflow','kind','physical', ...
    'title',configuration,'viewport',struct('x',0,'y',0,'zoom',1), ...
    'boundaryPorts',[],'assemblyDefaults',physical_defaults, ...
    'nodes',nodes,'edges',edges,'relationGroups',groups);
scenes = struct('workflow',struct('id','workflow','kind','workflow'), ...
    'physical',physical);
fixture = struct('id',['engine.configuration.' strrep(configuration,' ','-')], ...
    'legacyName',configuration,'templateDefinition',struct('rootSceneId','workflow','scenes',scenes), ...
    'DP',struct('F',engine_typed(F,'string',[1 numel(F)]), ...
    'SHAFT',engine_typed(shaft,'double',size(shaft)), ...
    'EXT',engine_typed(ext,'double',size(ext)), ...
    'WA_extraction',engine_typed(wa,'double',size(wa))));
end

function node = engine_scene_node(id, legacy_name, order, defaults)
node = struct('id',id,'componentId',['engine.gas-path.' legacy_name], ...
    'functionName','','instanceName',id,'nodeKind','physicalComponent', ...
    'legacyName',legacy_name,'legacyOrder',order,'assemblyDefaults',defaults, ...
    'position',struct('x',0,'y',0),'values',struct(),'resources',struct());
end

function group = engine_scene_group(id, relation, anchor, efficiency)
parameters = struct();
if strcmp(relation, 'shaft')
    parameters.E_mech = efficiency;
end
group = struct('id',id,'name',id,'relation',relation,'order',1, ...
    'anchorNodeId',anchor,'parameters',parameters);
end

function edge = engine_scene_edge(id, source, source_handle, target, target_handle, relation, group_id)
if nargin < 7
    group_id = '';
end
edge = struct('id',id,'source',source,'sourceHandle',source_handle, ...
    'target',target,'targetHandle',target_handle,'relation',relation, ...
    'groupId',group_id);
end

function value = engine_typed(payload, type_name, shape)
value = struct('value',payload,'type',type_name,'shape',shape);
end

function engine_assert_initialization_match(actual, expected)
fields = {'F','SHAFT','EXT','WA_extraction','NS','NW','TPR','EFFC','EFFT', ...
    'PRC','PRT','EB','HU','TO','E_motor','E_mech','TPRM','PRC_outerfan', ...
    'BYPASS_RATIO','flow','reheat','THRUST','WA','SECOND_FLOW', ...
    'PRESSURE_RATIO','STRUCTURE','NN','NC','NT','NB','NBY','NF','NM','NM1', ...
    'PWG','Q','N_ref','dN_partial','N','J','T_REQ','EFF_heat_exchange', ...
    'COMP_WP','TURB_WP','N_REF','M_ext'};
for k = 1:numel(fields)
    name = fields{k};
    if xor(isfield(actual,name), isfield(expected,name))
        error('engine:TestMissingField', 'Missing initialization field: %s', name);
    end
    if ~isfield(actual,name), continue; end
    if isnumeric(actual.(name)) && isnumeric(expected.(name))
        engine_assert_numeric_match(actual.(name), expected.(name), 0);
    else
        assert(isequaln(actual.(name), expected.(name)));
    end
end
assert(isfield(actual,'MAP') && isfield(expected,'MAP'));
assert(isequaln(actual.MAP, expected.MAP));
end

function engine_assert_numeric_match(actual, expected, tolerance)
assert(isequal(size(actual), size(expected)));
if isempty(actual), return; end
actual = double(actual);
expected = double(expected);
assert(isequal(isnan(actual), isnan(expected)));
mask = ~isnan(actual);
if any(mask(:))
    assert(max(abs(actual(mask) - expected(mask))) <= tolerance + 1e-8 * max(1,max(abs(expected(mask)))));
end
end

function engine_remove_output(output_directory)
if exist(output_directory, 'dir'), rmdir(output_directory, 's'); end
end

function engine_remove_outputs(output_directories)
for k = 1:numel(output_directories)
    engine_remove_output(output_directories{k});
end
end

function engine_assert_plot_manifest(result, phase, source)
assert(isstruct(result) && isstruct(result.files));
assert(strcmp(result.phase, phase));
assert(all(string({result.files.phase}) == string(phase)));
assert(all(string({result.files.fileName}) ~= ""));
assert(all(endsWith(string({result.files.fileName}), '.png')));
assert(~any(startsWith(string({result.files.fileName}), 'figure_')));
assert(all(string({result.files.source}) == string(source)));
assert(all(string({result.files.path}) ~= ""));
assert(strcmp(result.function, source));
end
