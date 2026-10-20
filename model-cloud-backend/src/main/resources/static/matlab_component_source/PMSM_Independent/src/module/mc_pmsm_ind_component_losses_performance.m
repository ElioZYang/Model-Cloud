function response = mc_pmsm_ind_component_losses_performance(request)
%COMPONENT_LOSSES_PERFORMANCE PMSM损耗与性能组件入口。
%
% 输入：request.inputs.motor_static
% 输出：
%   response.outputs.design_result
%   response.outputs.losses
%   response.outputs.performance

motor_static = require_component_input(request, 'motor_static', ...
    'PMSM:LossesPerformance:MissingMotorStatic', ...
    '损耗与性能组件缺少 request.inputs.motor_static。');
require_business_fields(motor_static, ...
    {'input', 'geometry', 'mass', 'slot', 'magnet', ...
     'winding', 'operating', 'thermal'}, ...
    'motor_static', 'PMSM:LossesPerformance:InvalidMotorStatic');

pmsm_input = motor_static.input;
geometry = motor_static.geometry;
mass_params = motor_static.mass;
slot_params = motor_static.slot;
mag_params = motor_static.magnet;
winding_params = motor_static.winding;
operating = motor_static.operating;

[losses, mag_params] = mc_pmsm_ind_calculate_total_losses( ...
    pmsm_input, operating, geometry, ...
    slot_params, mag_params, mass_params);

performance = mc_pmsm_ind_calculate_design_performance(operating, losses.total, geometry, mass_params);

if isfield(motor_static, 'intermediate') ...
        && isfield(motor_static.intermediate, 'rated_torque')
    rated_torque = motor_static.intermediate.rated_torque;
else
    rated_torque = operating.electric_power / operating.omega;
end

stator_outer_diameter_m = geometry.stator_OD / 1000;
core_length_m = geometry.core_length / 1000;

performance.torque_density = rated_torque ...
    / (pi * (stator_outer_diameter_m / 2)^2 * core_length_m);
performance.power_density = ...
    operating.electric_power / 1000 / mass_params.total;

design_result = struct();
design_result.input = pmsm_input;
design_result.geometry = geometry;
design_result.mass = mass_params;
design_result.slot = slot_params;
design_result.magnet = mag_params;
design_result.winding = winding_params;
design_result.operating = operating;
design_result.performance = performance;
design_result.losses = losses;
design_result.thermal = motor_static.thermal;

response = struct();
response.outputs = struct( ...
    'design_result', design_result, ...
    'losses', losses, ...
    'performance', performance);
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
