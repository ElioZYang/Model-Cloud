%% 铁耗计算子函数
function [P_fe] = mc_pmsm_calculate_iron_losses( D_is, Q,L, ...
    slot, k_fe,B_g, f, p,temp_Fe,m_tooth,m_yoke)
% 优化版铁耗计算函数（完整利用slot参数）
% 输入：
%   D_os - 定子外径 [m]
%   D_is - 定子内径 [m]
%   Q - 槽数
%   L - 铁芯长度 [m]
%   slot - 包含完整槽形参数的结构体（单位mm）
%         'opening_width',  b_open * 1000,      ... % [mm]
%         'opening_height', h_open * 1000,      ... % [mm]
%         'body_depth',     h_slot_body * 1000, ... % [mm]
%         'total_depth',    h_slot_available * 1000, ... % [mm]
%         'bottom_width',   b_bottom * 1000,    ... % [mm]
%         'yoke_height',    h_yoke_req * 1000,  ... % [mm]
%         'area',           A_slot * 1e6,       ... % [mm²]
%         'tooth_width',    b_tooth * 1000,     ... % [mm]
%         'tooth_flux_density', B_tooth,        ... % [T]
%         'yoke_flux_density_est', B_yoke_max   ... % [T]
%   B_g - 气隙磁密 [T]
%   f - 频率 [Hz]
%   p - 极对数
%   pole_type - 磁极类型（'SPM','IPM','VIPM'）
% 输出：
%   P_fe - 总铁耗 [W]
%   B_t - 齿部磁密 [T]
%   B_y - 轭部磁密 [T]

%% 参数预处理（单位转换）
h_yoke = slot.yoke_height / 1000;       % 轭部高 [m]
tooth_width = slot.tooth_width / 1000;  % 齿宽 [m]

%% 磁密计算（使用精确槽形参数）
% 1. 齿部磁密
t_s = pi * D_is / Q;                      % 齿距 [m]
B_t = B_g * t_s / tooth_width/k_fe;    % 齿部磁密 [T]

% 2. 轭部磁密
tau_p = pi * D_is / (2 * p);              % 极距 [m]
Phi_p = B_g * tau_p * L;         % 每极磁通 [Wb]
B_y = Phi_p / (2 * h_yoke * L* k_fe);           % 轭部磁密 [T]

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
P_tooth=steinmetz_iron_loss(B_t,f)*m_tooth;
P_yoke=steinmetz_iron_loss(B_y,f)*m_yoke;
P_fe = P_tooth + P_yoke;

end
function[P_Fe]=bertotti_iron_loss(Bm_single,f_single)
k_h = 0.105;          % 磁滞损耗系数 [W/(kg·Hz·T^n)]
n = 1.6;              % 磁滞指数
k_e = 3.2e-3;         % 涡流损耗系数 [W/(kg·Hz²·T²)]
k_c = 0.018;          % 附加损耗系数 [W/(kg·Hz^1.5·T^1.5)]


% 计算各损耗分量
P_h = k_h * f_single * (Bm_single)^n;          % 磁滞损耗
P_e = k_e * (f_single)^2 * (Bm_single)^2;      % 涡流损耗
P_c = k_c * (f_single)^1.5 * (Bm_single)^1.5;  % 附加损耗
P_Fe = P_h + P_e + P_c;                  % 总铁耗
end
function[P_Fe]=steinmetz_iron_loss(Bm,f)
    P15_50=2.5;
    alpha = 1.3;  % 频率幂次（工程典型值）
    beta = 1.6;   % 磁密幂次（工程典型值）
    
    % 铁耗计算公式
    P_Fe = P15_50 .* (f/50).^alpha .* (Bm/1.5).^beta;
end