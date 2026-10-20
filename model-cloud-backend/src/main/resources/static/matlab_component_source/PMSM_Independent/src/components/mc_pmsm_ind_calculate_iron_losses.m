%% 铁耗计算子函数
function iron_loss_W = mc_pmsm_ind_calculate_iron_losses(...
    stator_inner_diameter_m,slot_count,core_length_m, ...
    yoke_height_m,tooth_width_m,stacking_factor, ...
    airgap_flux_density_T,electrical_frequency_Hz,pole_pairs, ...
    stator_tooth_mass_kg,stator_yoke_mass_kg)
% 优化版铁耗计算函数（完整利用slot参数）
% 输入：
%   stator_inner_diameter_m - 定子内径 [m]
%   slot_count - 槽数
%   core_length_m - 铁芯长度 [m]
%   yoke_height_m, tooth_width_m - 轭高和齿宽 [m]
%   stacking_factor - 铁芯叠压系数
%   airgap_flux_density_T - 磁极覆盖区气隙磁密 [T]
%   electrical_frequency_Hz - 电频率 [Hz]
%   pole_pairs - 极对数
%   stator_tooth_mass_kg, stator_yoke_mass_kg - 齿/轭质量 [kg]
% 输出：
%   iron_loss_W - 总铁耗 [W]

%% 磁密计算（使用精确槽形参数）
% 1. 齿部磁密
slot_pitch_m = pi*stator_inner_diameter_m/slot_count;
tooth_flux_density_T = airgap_flux_density_T*slot_pitch_m ...
    /tooth_width_m/stacking_factor;

% 2. 轭部磁密
pole_pitch_m = pi*stator_inner_diameter_m/(2*pole_pairs);
flux_per_pole_Wb = airgap_flux_density_T ...
    * pole_pitch_m*core_length_m;
yoke_flux_density_T = flux_per_pole_Wb ...
    /(2*yoke_height_m*core_length_m*stacking_factor);

% 50WW350的典型系数（基于W/kg单位，在20°C下的基准值）
%     Kh = 25e-3;      % 磁滞损耗系数 [W/(kg * T^β * Hz)]
%     beta = 1.9;     % 斯坦梅茨指数，非整数
%     Kc_20 = 5e-5;   % 20°C时的经典涡流损耗系数 [W/(kg * T^2 * Hz^2)]
%     Ke = 1e-7;      % 异常损耗系数 [W/(kg * T^1.5 * Hz^1.5)]
%     
%     % --- 温度修正系数 ---
%     T_ref = 20;     % 参考温度 [°C]
%     alpha = 0.0045; % 硅钢片电阻率温度系数 [1/°C]，典型值0.004-0.006
% %     alpha = 0;
%     % 计算电阻率相对变化，并修正涡流损耗系数
%     rho_ratio = 1 + alpha * (temp_Fe - T_ref);
%     Kc = Kc_20 / rho_ratio;  % 涡流损耗系数与电阻率成反比
%     
% 
%     % 损耗计算（修正后的Bertotti模型，考虑温度影响）
%     P_tooth = ( Kh * f * (B_t^beta) + Kc * (f * B_t)^2 + Ke * (f * B_t)^1.5 ) * m_tooth;
%     P_yoke  = ( Kh * f * (B_y^beta) + Kc * (f * B_y)^2 + Ke * (f * B_y)^1.5 ) * m_yoke;

tooth_iron_loss_W = steinmetz_iron_loss( ...
    tooth_flux_density_T,electrical_frequency_Hz) ...
    * stator_tooth_mass_kg;
yoke_iron_loss_W = steinmetz_iron_loss( ...
    yoke_flux_density_T,electrical_frequency_Hz) ...
    * stator_yoke_mass_kg;
iron_loss_W = tooth_iron_loss_W + yoke_iron_loss_W;

end

function[P_Fe] = bertotti_iron_loss(Bm, f)
    k_h = 0.105;          % 磁滞损耗系数 [W/(kg·Hz·T^n)]
    n   = 1.6;              % 磁滞指数
    k_e = 3.2e-3;         % 涡流损耗系数 [W/(kg·Hz²·T²)]
    k_c = 0.018;          % 附加损耗系数 [W/(kg·Hz^1.5·T^1.5)]
    
    
    % 计算各损耗分量
    P_h  = k_h * f * (Bm)^n;          % 磁滞损耗
    P_e  = k_e * (f)^2 * (Bm)^2;      % 涡流损耗
    P_c  = k_c * (f)^1.5 * (Bm)^1.5;  % 附加损耗
    P_Fe = P_h + P_e + P_c;                        % 总铁耗
end

function[P_Fe] = steinmetz_iron_loss(Bm, f)
    P15_50 = 2.5;
    alpha  = 1.3;  % 频率幂次（工程典型值）
    beta   = 1.6;   % 磁密幂次（工程典型值）
    
    % 铁耗计算公式
    P_Fe = P15_50 .* (f/50).^alpha .* (Bm/1.5).^beta;
end
