%% 导线计算子函数
function [d_wire,A_wire] = mc_pmsm_calculate_wire_diameter(I_ph,J_target)
    % 基于电流密度和槽满率反推线径
    
    A_wire = I_ph / (J_target * 1e6);   % 导线截面积(m²)
    d_wire = sqrt(4*A_wire/pi)*1000;    % 导线直径(mm)
    
end