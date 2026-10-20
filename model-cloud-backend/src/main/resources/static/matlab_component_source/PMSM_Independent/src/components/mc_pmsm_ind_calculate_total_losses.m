function [losses, mag_params]= mc_pmsm_ind_calculate_total_losses(...
    pmsm_input,operating,geometry, ...
    slot_params, mag_params, mass_params)
%% 获取工况参数


operating_speed_rpm = operating.speed;
phase_current_A = operating.phase_current;
phase_resistance_ohm = operating.phase_resistance;
mechanical_angular_speed = operating.omega;
electrical_frequency_Hz = operating.frequency;
equivalent_airgap_flux_density_T = operating.airgap_flux_density;
electric_power_W = operating.electric_power;
%% 获取电机参数
phase_count = pmsm_input.N_phase;
parallel_paths = pmsm_input.a;
stacking_factor = pmsm_input.K_stack;
pole_arc_ratio = pmsm_input.arc_factor;
pole_region_airgap_flux_density_T = ...
    equivalent_airgap_flux_density_T/pole_arc_ratio;
pole_pairs = pmsm_input.pole_pairs;

stator_inner_diameter_m = geometry.stator_ID/1000;
rotor_outer_diameter_m = geometry.rotor_OD/1000;
rotor_inner_diameter_m = geometry.rotor_ID/1000;
core_length_m = geometry.core_length/1000;
air_gap_m = geometry.air_gap/1000;
slot_count = geometry.slot_number;
 
yoke_height_m = slot_params.yoke_height/1000;
tooth_width_m = slot_params.tooth_width/1000;

stator_tooth_mass_kg = mass_params.stator_tooth;
stator_yoke_mass_kg = mass_params.stator_yoke;
%% 铜耗计算
copper_loss_W = phase_count ...
    * (phase_current_A/parallel_paths)^2*phase_resistance_ohm;

%% 铁耗计算
iron_loss_W = mc_pmsm_ind_calculate_iron_losses( ...
    stator_inner_diameter_m,slot_count,core_length_m, ...
    yoke_height_m,tooth_width_m, ...
    stacking_factor,pole_region_airgap_flux_density_T, ...
    electrical_frequency_Hz,pole_pairs, ...
    stator_tooth_mass_kg,stator_yoke_mass_kg);

%% 杂散负载损耗
stray_loss_W = mc_pmsm_ind_calculate_extra_losses(electric_power_W);

%% 永磁体涡流损耗
[magnet_loss_W,mag_params] = mc_pmsm_ind_calculate_magnet_losses( ...
    mag_params,electrical_frequency_Hz, ...
    equivalent_airgap_flux_density_T,operating_speed_rpm);

%% 风摩损耗
rho_air = 1.29;
mu_air = 1.81e-5;
windage_loss_W = mc_pmsm_ind_calculate_windage_losses( ...
    rho_air,mu_air,mechanical_angular_speed, ...
    rotor_outer_diameter_m,rotor_inner_diameter_m, ...
    core_length_m,air_gap_m);

%% 轴承损耗
bearing_loss_W = 0;

%% 总损耗
total_loss_W = copper_loss_W + iron_loss_W + magnet_loss_W ...
    + windage_loss_W + bearing_loss_W + stray_loss_W;

%% 组装损耗参数
losses = struct( ...
    'copper', copper_loss_W, ...
    'iron', iron_loss_W, ...
    'magnet', magnet_loss_W, ...
    'windage', windage_loss_W, ...
    'bearing', bearing_loss_W, ...
    'stray', stray_loss_W, ...
    'total', total_loss_W);
end