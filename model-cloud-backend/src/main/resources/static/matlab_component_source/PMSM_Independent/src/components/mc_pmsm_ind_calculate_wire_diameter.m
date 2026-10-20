%% 导线计算子函数
function [wire_diameter_mm,wire_area_m2] = mc_pmsm_ind_calculate_wire_diameter( ...
    conductor_current_A, target_current_density_A_per_mm2)
    % 基于电流密度和槽满率反推线径
    wire_area_m2 = conductor_current_A ...
        /(target_current_density_A_per_mm2*1e6);
    wire_diameter_mm = sqrt(4*wire_area_m2/pi)*1000;
end
