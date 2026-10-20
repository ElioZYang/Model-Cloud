function [slot_params,winding_params,stator_outer_diameter_m,operating] = ...
    calculate_stator_winding_design( ...
        pmsm_input,stator_inner_diameter_m, ...
        stator_outer_diameter_m,core_length_m, ...
        slot_count,conductors_per_slot, ...
        operating,electric_loading_A_per_m)
% 定子槽形与绕组设计
% 计算槽形、导线尺寸、绕组长度、相电阻及定子齿轭质量。

%% 从输入结构体获取本模块参数
phase_count = pmsm_input.N_phase;
parallel_paths = pmsm_input.a;
copper_resistivity_20C = pmsm_input.rho_Cu;
copper_temperature_coefficient = pmsm_input.alpha_Cu;

% 基础工况由 prepare_design_operating 统一处理。
phase_current_A = operating.phase_current;
electrical_frequency_Hz = operating.frequency;
copper_temperature_C = operating.temp_Cu;

stacking_factor = pmsm_input.K_stack;
pole_arc_ratio = pmsm_input.arc_factor;
equivalent_airgap_flux_density_T = pmsm_input.B_g;
pole_region_airgap_flux_density_T = ...
    equivalent_airgap_flux_density_T/pole_arc_ratio;

X_tooth = pmsm_input.X_tooth;
X_yoke = pmsm_input.X_yoke;
tooth_flux_density_T = pmsm_input.B_tooth;
yoke_flux_density_T = pmsm_input.B_yoke;

slot_fill = pmsm_input.slot_fill;
J_max = pmsm_input.J_max;
pole_pairs = pmsm_input.pole_pairs;

%% 槽满率验证及最小槽面积
[~,wire_area_m2] = calculate_wire_diameter( ...
    phase_current_A/parallel_paths,J_max);
minimum_slot_area_m2 = conductors_per_slot*wire_area_m2/slot_fill;

%% 槽形优化设计
[slot_params,stator_outer_diameter_m] = calculate_slot_geometry_new( ...
    stator_inner_diameter_m,stator_outer_diameter_m, ...
    minimum_slot_area_m2,slot_count,pole_pairs, ...
    stacking_factor,slot_fill, ...
    X_tooth,X_yoke, ...
    pole_region_airgap_flux_density_T, ...
    tooth_flux_density_T,yoke_flux_density_T);

%% 根据实际槽面积计算导线尺寸
wire_area_m2 = slot_params.area_body ...
    * slot_fill/conductors_per_slot/1e6;
wire_diameter_mm = 2*sqrt(wire_area_m2/pi)*1e3;

%% 计算工作温度下的铜电阻率
copper_resistivity_operating = copper_resistivity_20C ...
    * (1+copper_temperature_coefficient*(copper_temperature_C-20));

%% 计算每相绕组长度
slot_conductor_length_per_phase = conductors_per_slot ...
    * slot_count*core_length_m/phase_count;
% 端部绕组长度暂按槽内绕组长度的10%估算。
end_winding_length_per_phase = .1*slot_conductor_length_per_phase;
conductor_length_per_phase = slot_conductor_length_per_phase ...
    + end_winding_length_per_phase;

%% 计算每相绕组交流电阻
ac_resistance_per_m = calculate_copper_resistance( ...
    wire_diameter_mm,electrical_frequency_Hz, ...
    copper_resistivity_operating,conductors_per_slot, ...
    wire_area_m2);
phase_resistance_ohm = ac_resistance_per_m*conductor_length_per_phase;

%% 组装绕组参数
winding_params = struct( ...
    'pole_pairs', pole_pairs, ...
    'conductors_per_slot', conductors_per_slot, ...
    'wire_dia', wire_diameter_mm, ...
    'wire_area', wire_area_m2, ...
    'parallel_paths', parallel_paths, ...
    'conductor_length_per_phase', conductor_length_per_phase, ...
    'resistance_per_phase', phase_resistance_ohm, ...
    'connection', 'star');

%% 补齐依赖绕组结果的工况
wire_area_mm2 = winding_params.wire_area*1e6;
current_density_A_per_mm2 = ...
    (phase_current_A/parallel_paths)/wire_area_mm2;

phase_voltage_V = operating.phase_voltage;
phase_emf_V = -1;
switch operating.cal_mode
    case 0
        phase_emf_V = phase_voltage_V;
    case 1
        phase_emf_V = phase_voltage_V ...
            + phase_current_A/parallel_paths*phase_resistance_ohm;
    case -1
        phase_emf_V = phase_voltage_V ...
            - phase_current_A/parallel_paths*phase_resistance_ohm;
end

operating.phase_resistance = phase_resistance_ohm;
operating.electro_potential = phase_emf_V;
operating.electric_loading = electric_loading_A_per_m;
operating.current_density = current_density_A_per_mm2;
end
