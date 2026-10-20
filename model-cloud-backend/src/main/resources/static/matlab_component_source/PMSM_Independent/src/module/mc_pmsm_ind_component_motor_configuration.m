function response = mc_pmsm_ind_component_motor_configuration(request)
%COMPONENT_MOTOR_CONFIGURATION PMSM电机设计配置组件入口。
%
% 输入：
%   request.parameters.electric_power_kW 设计点电功率，单位kW。
%   request.parameters.rated_speed_rpm   设计点额定转速，单位rpm。
%
% 输出：
%   response.outputs.design_spec         PMSM设计输入对象。

require_struct_field(request, 'parameters', ...
    'PMSM:MotorConfiguration:MissingParameters', ...
    '电机配置组件缺少 request.parameters。');

parameters = request.parameters;
electric_power_kW = require_finite_scalar(parameters, ...
    'electric_power_kW', ...
    'PMSM:MotorConfiguration:MissingElectricPower', ...
    '电机配置组件缺少 request.parameters.electric_power_kW。');
rated_speed_rpm = require_finite_scalar(parameters, ...
    'rated_speed_rpm', ...
    'PMSM:MotorConfiguration:MissingRatedSpeed', ...
    '电机配置组件缺少 request.parameters.rated_speed_rpm。');

if rated_speed_rpm <= 0
    error('PMSM:MotorConfiguration:InvalidRatedSpeed', ...
        'request.parameters.rated_speed_rpm 必须大于 0。');
end

config_file = '';
if isfield(request, 'resources') && isstruct(request.resources) ...
        && isfield(request.resources, 'motor_config_file')
    config_file = request.resources.motor_config_file;
end

configuration = struct('source', 'default', 'templateVersion', '1.0');
if isempty(config_file)
    pmsm_input = mc_pmsm_ind_INPUT_ELECTRIC();
else
    pmsm_input = mc_pmsm_ind_INPUT_ELECTRIC(config_file);
    configuration.source = 'uploaded';
    configuration = copy_optional_resource_field(request.resources, ...
        configuration, 'motor_config_id', 'configId');
    configuration = copy_optional_resource_field(request.resources, ...
        configuration, 'motor_config_sha256', 'sha256');
    configuration = copy_optional_resource_field(request.resources, ...
        configuration, 'motor_config_template_version', 'templateVersion');
    configuration = copy_optional_resource_field(request.resources, ...
        configuration, 'motor_config_original_filename', 'originalFileName');
end
pmsm_input.configuration = configuration;

design_spec = struct( ...
    'config', pmsm_input, ...
    'config_source', configuration.source, ...
    'configuration', configuration, ...
    'electric_power_kW', electric_power_kW, ...
    'rated_speed_rpm', rated_speed_rpm);

response = struct();
response.outputs = struct('design_spec', design_spec);
end

function target = copy_optional_resource_field(source, target, source_name, target_name)
if isfield(source, source_name)
    target.(target_name) = source.(source_name);
end
end

function require_struct_field(value, field_name, error_id, message)
if ~isstruct(value) || ~isfield(value, field_name) ...
        || ~isstruct(value.(field_name))
    error(error_id, message);
end
end

function result = require_finite_scalar(value, field_name, error_id, message)
if ~isfield(value, field_name)
    error(error_id, message);
end
result = value.(field_name);
if ~isnumeric(result) || ~isscalar(result) || ~isfinite(result)
    error('PMSM:MotorConfiguration:InvalidParameter', ...
        'request.parameters.%s 必须是有限数值标量。', field_name);
end
end
