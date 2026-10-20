function magnet_thickness_m = calculate_pm_thickness( ...
    stator_inner_diameter_m,core_length_m,air_gap_m, ...
    airgap_flux_density_T,remanence_T,coercivity_kA_per_m, ...
    carter_factor,pole_pairs,pole_arc_ratio, ...
    slot_opening_width_m,slot_opening_depth_m)
% 直接求解永磁体厚度和漏磁系数的联立方程
%
% 输入参数：
%   stator_inner_diameter_m, core_length_m, air_gap_m - 几何量 [m]
%   airgap_flux_density_T, remanence_T - 磁密 [T]
%   coercivity_kA_per_m - 矫顽力 [kA/m]
%   carter_factor, pole_pairs, pole_arc_ratio - 磁路参数
%   slot_opening_width_m, slot_opening_depth_m - 槽口尺寸 [m]
%
% 输出参数：
%   magnet_thickness_m - 永磁体厚度 [m]

%% 常数定义
mu0 = 4 * pi * 1e-7;  % 真空磁导率

%% 计算中间几何参数
pole_pitch_m = pi*stator_inner_diameter_m/(2*pole_pairs);
pole_arc_width_m = pole_arc_ratio*pole_pitch_m;

%% 计算系数

% 基准厚度值
base_thickness_m = airgap_flux_density_T*air_gap_m*carter_factor ...
    /(mu0*coercivity_kA_per_m);

% 漏磁路径系数
side_leakage_coefficient = 2/(pole_pitch_m-pole_arc_width_m);
end_leakage_coefficient = 2/core_length_m;
slot_leakage_ratio = slot_opening_width_m/slot_opening_depth_m;

% 耦合系数
coupling_coefficient = air_gap_m/pole_arc_width_m ...
    * airgap_flux_density_T/remanence_T;

%% 构建二次方程系数
quadratic_a = coupling_coefficient ...
    * (side_leakage_coefficient+end_leakage_coefficient);
quadratic_b = 1-airgap_flux_density_T/remanence_T ...
    - coupling_coefficient*slot_leakage_ratio;
quadratic_c = -base_thickness_m;

discriminant = quadratic_b^2-4*quadratic_a*quadratic_c;

% 求根
magnet_thickness_m = (-quadratic_b+sqrt(discriminant)) ...
    /(2*quadratic_a);

end
