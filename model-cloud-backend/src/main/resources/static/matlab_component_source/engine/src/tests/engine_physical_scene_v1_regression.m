function report = engine_physical_scene_v1_regression()
%ENGINE_PHYSICAL_SCENE_V1_REGRESSION V1 装配契约 vs 预设构型 回归。
% 读取黄金夹具（contracts/matlab/fixtures/engine）中三构型展开图的
% EnginePhysicalSceneV1 装配，交由 ENGINE_SCENE_ASSEMBLY 推导 DP，并与
% INPUT_TURBO 预设构型的 DP、设计点和短扫描结果逐项对比。
root = 'C:/Users/xiong/Documents/Model-Cloud-ExtendML/contracts/matlab/fixtures/engine';
pairs = {'engine.configuration.ducted-fan', 'ducted fan'; ...
    'engine.configuration.turboshaft', 'turboshaft'; ...
    'engine.configuration.mixed-turbofan', 'mixed turbofan'};
report = repmat(struct('configuration','', 'passed',false, 'stage','', ...
    'message',''), size(pairs, 1), 1);
old_directory = pwd;
old_path = path;
cleanup = onCleanup(@() restore_environment(old_directory, old_path));
for k = 1:size(pairs, 1)
    configuration = pairs{k, 1};
    preset = pairs{k, 2};
    report(k).configuration = configuration;
    try
        graph = jsondecode(fileread(fullfile(root, ...
            [configuration '.expanded-graph.json'])));
        first_node = engine_first_element(graph.nodes);
        assembly_json = first_node.values.assembly_json;
        decoded = jsondecode(assembly_json);
        assert(strcmp(string(decoded.schemaVersion), "engine.physical-scene.v1"), ...
            '装配不是 EnginePhysicalSceneV1 契约');
        for legacy = {'F','SHAFT','EXT','NS','NW','WA_extraction'}
            assert(~isfield(decoded, legacy{1}), ...
                'V1 装配不应携带 Java 计算的 %s', legacy{1});
        end

        scene_dp = component_engine_initialize_configuration(assembly_json, 60, 0, 3000);
        preset_dp = component_engine_initialize_configuration(preset, 60, 0, 3000);

        % 拓扑与组语义必须精确一致（发动机语义已唯一归属 MATLAB）。
        assert(isequal(scene_dp.F, preset_dp.F), 'F 不一致');
        assert(isequal(scene_dp.SHAFT, preset_dp.SHAFT), 'SHAFT 不一致');
        assert(isequal(scene_dp.EXT, preset_dp.EXT), 'EXT 不一致');
        assert(scene_dp.NS == preset_dp.NS, 'NS 不一致');
        assert(scene_dp.NW == preset_dp.NW, 'NW 不一致');
        assert(isequal(scene_dp.WA_extraction, preset_dp.WA_extraction), 'WA_extraction 不一致');

        % 其余初始化字段：双方都存在时必须一致（scene 侧独有的
        % assemblyDefaults 字段属于构型默认值，记录但不判失败）。
        engine_compare_common_fields(scene_dp, preset_dp);

        scene_dp = component_engine_apply_design_conditions(scene_dp, 0, 0, ...
            1000 * ones(scene_dp.NS, 1));
        preset_dp = component_engine_apply_design_conditions(preset_dp, 0, 0, ...
            1000 * ones(preset_dp.NS, 1));
        [scene_dp, scene_xd] = component_engine_solve_design_point(scene_dp);
        [preset_dp, preset_xd] = component_engine_solve_design_point(preset_dp);
        engine_compare_numeric(scene_xd, preset_xd, 1e-8);
        engine_compare_numeric(scene_dp.YD, preset_dp.YD, 1e-8);

        scene_scan = engine_capture_envelope(scene_dp, 3, 4, 4);
        preset_scan = engine_capture_envelope(preset_dp, 3, 4, 4);
        if scene_scan.completed && preset_scan.completed
            engine_compare_numeric(scene_scan.THRUST, preset_scan.THRUST, 1e-8);
            engine_compare_numeric(scene_scan.TIT, preset_scan.TIT, 1e-8);
            engine_compare_numeric(scene_scan.OP.THRUST, preset_scan.OP.THRUST, 1e-8);
            engine_compare_numeric(scene_scan.X0, preset_scan.X0, 1e-8);
            engine_compare_numeric(scene_scan.DX, preset_scan.DX, 1e-8);
            assert(isequaln(scene_scan.MISSION.G.MAP, preset_scan.MISSION.G.MAP));
        else
            % 原模型不收敛或抛出原生异常时，两条路径必须暴露相同异常。
            assert(~scene_scan.completed && ~preset_scan.completed, '扫描完成状态不一致');
            assert(strcmp(scene_scan.identifier, preset_scan.identifier), '异常标识不一致');
        end
        report(k).passed = true;
    catch err
        report(k).stage = 'failed';
        stack_lines = strtrim(string(splitlines(evalc('disp(err.stack)'))));
        stack_lines = stack_lines(stack_lines ~= "");
        if isempty(stack_lines), first_line = ''; else, first_line = char(stack_lines(1)); end
        report(k).message = sprintf('%s / %s / %s', err.message, err.identifier, first_line);
    end
end
end

function capture = engine_capture_envelope(DP, power_points, speed_points, altitude_points)
capture = struct('completed', false, 'identifier', '', 'message', '', ...
    'MISSION', [], 'THRUST', [], 'TIT', [], 'OP', [], 'X0', [], 'DX', []);
try
    [capture.MISSION, capture.THRUST, capture.TIT, ~, ~, ~, ...
        capture.OP, capture.X0, capture.DX] = ...
        component_run_engine_envelope(DP, power_points, speed_points, altitude_points);
    capture.completed = true;
catch exception
    capture.identifier = exception.identifier;
    capture.message = exception.message;
end
end

function engine_compare_common_fields(actual, expected)
fields = {'TPR','EFFC','EFFT','PRC','PRT','EB','HU','TO','E_motor','E_mech', ...
    'TPRM','PRC_outerfan','BYPASS_RATIO','flow','reheat','THRUST','WA', ...
    'SECOND_FLOW','PRESSURE_RATIO','NN','NC','NT','NB','NBY','NF','NM','NM1'};
for k = 1:numel(fields)
    name = fields{k};
    if isfield(actual, name) && isfield(expected, name)
        if isnumeric(actual.(name)) && isnumeric(expected.(name))
            engine_compare_numeric(actual.(name), expected.(name), 0);
        else
            assert(isequaln(actual.(name), expected.(name)), '字段 %s 不一致', name);
        end
    end
end
assert(isfield(actual, 'MAP') && isfield(expected, 'MAP'));
assert(isequaln(actual.MAP, expected.MAP));
end

function engine_compare_numeric(actual, expected, tolerance)
assert(isequal(size(actual), size(expected)), ...
    '数组形状不一致: %s vs %s', mat2str(size(actual)), mat2str(size(expected)));
if isempty(actual), return; end
actual = double(actual);
expected = double(expected);
assert(isequal(isnan(actual), isnan(expected)));
mask = ~isnan(actual);
if any(mask(:))
    assert(max(abs(actual(mask) - expected(mask))) <= ...
        tolerance + 1e-8 * max(1, max(abs(expected(mask)))), '数值超出容差');
end
end

function restore_environment(old_directory, old_path)
cd(old_directory);
path(old_path);
end

function value = engine_first_element(list)
if iscell(list)
    value = list{1};
else
    value = list(1);
end
end
