function [R_ac, K_skin, K_proximity] = mc_pmsm_calculate_copper_resistance(...
    d_wire, f_elec, temp_Cu, rho_Cu, ...
    N_s, A_slot, A_wire, slot_fill_factor)
% 计算考虑集肤效应和邻近效应的交流电阻
% 输入:
%   d_wire - 导线直径 [mm]
%   f_elec - 电频率 [Hz]
%   temp_Cu - 铜线工作温度 [°C]
%   rho_Cu - 铜电阻率 [Ω·m]
%   N_s - 每槽导体数
%   A_slot - 槽面积 [m²]
%   A_wire - 单根导线截面积 [m²]
%   slot_fill_factor - 槽满率

    % 导线直径转换为米
    d_wire_m = d_wire / 1000;
    
    % 1. 计算集肤效应系数
    % 集肤深度
    mu_0 = 4*pi*1e-7;
    delta = sqrt(rho_Cu / (pi * f_elec * mu_0));
    
    % 集肤效应系数 (Dowell公式简化)
    xi = d_wire_m / (sqrt(2) * delta);
    if xi <= 2.8
        K_skin = 1 + xi^4 / 48;  % 低频近似
    else
        K_skin = 0.5 * xi + 0.25 + 3/(64*xi);  % 高频近似
    end
    
    % 2. 计算邻近效应系数
    % 槽内导体层数估计
    N_layers = ceil(sqrt(N_s));  % 简化估计层数
    
    % 导体在槽中的高度 (简化模型)
    h_conductor = sqrt(A_slot * slot_fill_factor / N_s);
    
    % 邻近效应系数 (Dowell公式)
    phi = xi^2;
    K_proximity = 1 + (N_layers^2 - 1) * phi / 9;
    
    % 3. 总交流电阻系数
    K_ac = K_skin * K_proximity;
%     K_ac = 1;
    % 4. 计算单位长度交流电阻
    R_dc_per_m = rho_Cu / A_wire;
    R_ac_per_m = R_dc_per_m * K_ac;
    
    % 返回单位长度电阻和系数
    R_ac = R_ac_per_m;
    
    % 显示频率影响信息
%     if f_elec > 100
%         fprintf('频率影响: f=%.0fHz, 集肤系数=%.3f, 邻近系数=%.3f, 总系数=%.3f\n', ...
%             f_elec, K_skin, K_proximity, K_ac);
%     end
end