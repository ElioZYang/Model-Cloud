function response = mc_pmsm_ind_component_dimensions_electromagnetic(request)
%COMPONENT_DIMENSIONS_ELECTROMAGNETIC PMSM尺寸与电磁设计组件入口。
%
% 输入：
%   request.inputs.design_spec.config
%   request.inputs.design_spec.electric_power_kW
%   request.inputs.design_spec.rated_speed_rpm
%
% 输出：
%   response.outputs.design_draft

design_spec = require_component_input(request, 'design_spec', ...
    'PMSM:DimensionsElectromagnetic:MissingDesignSpec', ...
    '尺寸与电磁设计组件缺少 request.inputs.design_spec。');
require_business_fields(design_spec, ...
    {'config', 'electric_power_kW', 'rated_speed_rpm'}, ...
    'design_spec', 'PMSM:DimensionsElectromagnetic:InvalidDesignSpec');

pmsm_input        = design_spec.config;
electric_power_kW = design_spec.electric_power_kW;
rated_speed_rpm   = design_spec.rated_speed_rpm;

if ~isnumeric(electric_power_kW) || ~isscalar(electric_power_kW) ...
        || ~isfinite(electric_power_kW)
    error('PMSM:DimensionsElectromagnetic:InvalidElectricPower', ...
        'design_spec.electric_power_kW 必须是有限数值标量。');
end
if ~isnumeric(rated_speed_rpm) || ~isscalar(rated_speed_rpm) ...
        || ~isfinite(rated_speed_rpm) || rated_speed_rpm <= 0
    error('PMSM:DimensionsElectromagnetic:InvalidRatedSpeed', ...
        'design_spec.rated_speed_rpm 必须是大于 0 的有限数值标量。');
end

%% 输入参数处理（新版统一工况）
operating = mc_pmsm_ind_prepare_design_operating(pmsm_input,electric_power_kW,rated_speed_rpm);
electric_power_W = operating.electric_power;

%% 1. 主要尺寸计算
[stator_inner_diameter_m, stator_outer_diameter_m, ...
    core_length_m, slot_count, conductors_per_slot, ...
    electric_loading_A_per_m,pmsm_input] = mc_pmsm_ind_calculate_main_dimensions( ...
        pmsm_input, operating);

pmsm_input.N_cs = conductors_per_slot;
pmsm_input.A_s = electric_loading_A_per_m;
pole_pairs = pmsm_input.pole_pairs;

%% 2. 定子槽形与绕组设计
[slot_params, winding_params, stator_outer_diameter_m, operating] = ...
    mc_pmsm_ind_calculate_stator_winding_design( ...
        pmsm_input, ...
        stator_inner_diameter_m, stator_outer_diameter_m, ...
        core_length_m, slot_count, conductors_per_slot, ...
        operating,electric_loading_A_per_m);

%% 3. 转子与磁钢设计
[rotor_outer_diameter_m, rotor_inner_diameter_m, ...
    air_gap_m, mag_params] = mc_pmsm_ind_calculate_rotor_magnet_design( ...
        pmsm_input, stator_inner_diameter_m, core_length_m, ...
        slot_params, operating);

geometry = struct( ...
    'stator_OD', stator_outer_diameter_m * 1000, ...
    'stator_ID', stator_inner_diameter_m * 1000, ...
    'rotor_OD', rotor_outer_diameter_m * 1000, ...
    'rotor_ID', rotor_inner_diameter_m * 1000, ...
    'core_length', core_length_m * 1000, ...
    'air_gap', air_gap_m * 1000, ...
    'slot_number', slot_count, ...
    'pole_pairs', pole_pairs);

design_draft = struct();
design_draft.input = pmsm_input;
design_draft.geometry = geometry;
design_draft.slot = slot_params;
design_draft.magnet = mag_params;
design_draft.winding = winding_params;
design_draft.operating = operating;
design_draft.thermal = pmsm_input.thermal;
design_draft.intermediate = struct( ...
    'rated_torque', operating.rated_torque);

response = struct();
response.outputs = struct('design_draft', design_draft);
end

function result = require_component_input(request, field_name, error_id, message)
if ~isstruct(request) || ~isfield(request, 'inputs') ...
        || ~isstruct(request.inputs) || ~isfield(request.inputs, field_name)
    error(error_id, message);
end
result = request.inputs.(field_name);
if ~isstruct(result)
    error(error_id, '%s 必须是结构体。', message);
end
end

function require_business_fields(value, fields, value_name, error_id)
for index = 1:numel(fields)
    if ~isfield(value, fields{index})
        error(error_id, '%s 缺少字段 %s。', value_name, fields{index});
    end
end
end
