function [stator_inner_diameter_m,stator_outer_diameter_m, ...
    core_length_m,slot_count,conductors_per_slot, ...
    electric_loading_A_per_m,pmsm_input] = mc_pmsm_ind_calculate_main_dimensions( ...
    pmsm_input,operating)
% 主要尺寸计算（D^2L 法）。
% 输出依次为定子内/外径、铁芯长度、槽数、每槽导体数和线负荷。

% operating 提供功率幅值 [W]、转速 [rpm] 和相电流 [A]。
electric_power_W = operating.electric_power;
rated_speed_rpm = operating.speed;
phase_current_A = operating.phase_current;

% 从结构体获取需要的参数
K_winding  = pmsm_input.K_w;
parallel_paths = pmsm_input.a;
equivalent_airgap_flux_density_T = pmsm_input.B_g;
conductors_per_slot = pmsm_input.N_cs;
slot_count = pmsm_input.N_slot;
slot_pitch = pmsm_input.slot_pitch/1e3;% 换算单位-> cm
X_stator   = pmsm_input.X_stator;
X_length   = pmsm_input.X_length;

output_coefficient = pi^2/60*K_winding ...
    * equivalent_airgap_flux_density_T*rated_speed_rpm;
sigma_max = 48000;
max_electric_loading_A_per_m = ...
    sigma_max/equivalent_airgap_flux_density_T;

% 核心公式：
% P   = C*A_s*D^2*L
% electric_loading = conductors_per_slot*phase_current*slot_count ...
%     /(parallel_paths*pi*stator_inner_diameter)
% 当槽数不确定时，slot_count≈pi*stator_inner_diameter/slot_pitch。

if conductors_per_slot < 0
    electric_loading_A_per_m = min( ...
        max_electric_loading_A_per_m,pmsm_input.A_s);
    % 计算系数k
    k = (parallel_paths*pi/(phase_current_A*slot_count)) ...
        * (electric_power_W/(output_coefficient*X_length))^(1/3);
    % 计算初始N_cs
    initial_conductors_per_slot = ...
        k*electric_loading_A_per_m^(2/3);
    % 取最接近的整数
    integer_conductors_per_slot = floor(initial_conductors_per_slot);
    % 确保为正整数
    integer_conductors_per_slot = max(integer_conductors_per_slot,1);
    % 计算对应的A_s
    electric_loading_A_per_m = ...
        (integer_conductors_per_slot/k)^(3/2);
    diameter_squared_length_m3 = ...
        electric_power_W/(output_coefficient*electric_loading_A_per_m);
    stator_inner_diameter_m = ...
        (diameter_squared_length_m3/X_length)^(1/3);
    if slot_count < 0
        slot_count = max( ...
            round(pi*stator_inner_diameter_m/slot_pitch),2);
    end
    conductors_per_slot = round( ...
        parallel_paths*electric_loading_A_per_m*pi ...
        * stator_inner_diameter_m/phase_current_A/slot_count);
else
    if slot_count < 0
        diameter_squared_length_m3 = max( ...
            electric_power_W*parallel_paths*slot_pitch ...
            /(output_coefficient*conductors_per_slot*phase_current_A), ...
            electric_power_W ...
            /(output_coefficient*max_electric_loading_A_per_m));
        stator_inner_diameter_m = ...
            (diameter_squared_length_m3/X_length)^(1/3);
        slot_count = max( ...
            round(pi*stator_inner_diameter_m/slot_pitch),2);
    end
    %将A_s_max的约束转换为N_cs_max的约束
    max_conductors_per_slot = round( ...
        pi*parallel_paths*max_electric_loading_A_per_m^(2/3) ...
        * electric_power_W^(1/3) ...
        /(output_coefficient^(1/3)*phase_current_A ...
        * slot_count*X_length^(1/3)));
    conductors_per_slot = min( ...
        conductors_per_slot,max_conductors_per_slot);
    diameter_length_m2 = electric_power_W/output_coefficient ...
        * pi*parallel_paths ...
        /conductors_per_slot/phase_current_A/slot_count;
    stator_inner_diameter_m = sqrt(diameter_length_m2/X_length);
    electric_loading_A_per_m = conductors_per_slot*phase_current_A ...
        /parallel_paths*slot_count/pi/stator_inner_diameter_m;
end

% L = (strcmpi(cooling,'liquid')*1.2 + 0.8) * D_is; % 铁芯长度(m)
core_length_m = X_length*stator_inner_diameter_m;
% D_os = D_is * (1.7 - 0.1*(strcmpi(pole_type,'IPM'))); % 定子外径(m)
stator_outer_diameter_m = stator_inner_diameter_m/X_stator;

% 保存主尺寸模块确定的实际设计值。
pmsm_input.N_cs = conductors_per_slot;
pmsm_input.A_s  = electric_loading_A_per_m;

end
