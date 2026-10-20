function [ac_resistance_per_m, skin_effect_factor, proximity_factor] = ...
    calculate_copper_resistance( ...
        wire_diameter_mm,electrical_frequency_Hz, ...
        copper_resistivity_ohm_m,conductors_per_slot, ...
        wire_area_m2)
% 计算考虑集肤效应和邻近效应的交流电阻
% 输入:
%   wire_diameter_mm - 导线直径 [mm]
%   electrical_frequency_Hz - 电频率 [Hz]
%   copper_resistivity_ohm_m - 当前温度下的铜电阻率 [Ω·m]
%   conductors_per_slot - 每槽导体数
%   wire_area_m2 - 单根导线截面积 [m²]

    % 导线直径转换为米
    wire_diameter_m = wire_diameter_mm/1000;
    
    % 1. 计算集肤效应系数
    % 集肤深度
    mu_0 = 4*pi*1e-7;
    skin_depth_m = sqrt(copper_resistivity_ohm_m ...
        /(pi*electrical_frequency_Hz*mu_0));
    
    % 集肤效应系数 (Dowell公式简化)
    xi = wire_diameter_m/(sqrt(2)*skin_depth_m);
    if xi <= 2.8
        skin_effect_factor = 1+xi^4/48;
    else
        skin_effect_factor = 0.5*xi+0.25+3/(64*xi);
    end
    
    % 2. 计算邻近效应系数
    % 槽内导体层数估计
    conductor_layers = ceil(sqrt(conductors_per_slot));
    
    % 邻近效应系数 (Dowell公式)
    phi = xi^2;
    proximity_factor = 1+(conductor_layers^2-1)*phi/9;
    
    % 3. 总交流电阻系数
    ac_resistance_factor = skin_effect_factor*proximity_factor;
    % 4. 计算单位长度交流电阻
    dc_resistance_per_m = copper_resistivity_ohm_m/wire_area_m2;
    ac_resistance_per_m = dc_resistance_per_m*ac_resistance_factor;
    
    % 显示频率影响信息
%     if f_elec > 100
%         fprintf('频率影响: f=%.0fHz, 集肤系数=%.3f, 邻近系数=%.3f, 总系数=%.3f\n', ...
%             f_elec, K_skin, K_proximity, K_ac);
%     end
end
