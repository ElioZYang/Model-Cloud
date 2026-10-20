function performance = mc_pmsm_ind_calculate_design_performance(operating,total_loss_W,geometry,mass_params)
%% 获取工况参数
operation_mode = operating.cal_mode;
electric_power_W = operating.electric_power;
mechanical_power_W = -1;
efficiency = -1;
%% 机械功率与效率
switch operation_mode
    case 0
        efficiency = 1;
        mechanical_power_W = 0;

    case 1
        mechanical_power_W = electric_power_W + total_loss_W;
        efficiency = electric_power_W/mechanical_power_W;

    case -1
        mechanical_power_W = electric_power_W - total_loss_W;
        efficiency = mechanical_power_W/electric_power_W;
        
end

%% 组装性能参数
performance = struct( ...
    'rated_speed', operating.speed, ...
    'speed', operating.speed, ...
    'frequency', operating.frequency, ...
    'power', operation_mode*electric_power_W, ...
    'mechanical_power', operation_mode*mechanical_power_W, ...
    'efficiency', efficiency, ...
    'voltage', operating.phase_voltage, ...
    'electro_potential', operating.electro_potential, ...
    'current', operating.phase_current, ...
    'electric_loading', operating.electric_loading, ...
    'current_density', operating.current_density);

% 两参数调用保留原有输出；设计点额外提供几何和质量。
if nargin == 4
    stator_outer_diameter_m = geometry.stator_OD/1000;
    core_length_m = geometry.core_length/1000;
    performance.torque_density = operating.rated_torque ...
        /(pi*(stator_outer_diameter_m/2)^2*core_length_m);
    performance.power_density = operating.electric_power/1000/mass_params.total;
end
end
