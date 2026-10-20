%% 核心损耗计算子函数（考虑温度影响）
function [P_fe,m_tooth,m_yoke] = mc_pmsm_core_loss(B_t, B_y, f, D_os, D_is, Q, L, slot,temp_Fe)
% 新增输入参数：temperature - 定子工作温度 [°C]

% 50WW350的典型系数（基于W/kg单位，在20°C下的基准值）
    Kh = 25e-3;      % 磁滞损耗系数 [W/(kg * T^β * Hz)]
    beta = 1.9;     % 斯坦梅茨指数，非整数
    Kc_20 = 5e-5;   % 20°C时的经典涡流损耗系数 [W/(kg * T^2 * Hz^2)]
    Ke = 1e-7;      % 异常损耗系数 [W/(kg * T^1.5 * Hz^1.5)]
    
    % --- 温度修正系数 ---
    T_ref = 20;     % 参考温度 [°C]
    alpha = 0.0045; % 硅钢片电阻率温度系数 [1/°C]，典型值0.004-0.006
%     alpha = 0;
    % 计算电阻率相对变化，并修正涡流损耗系数
    rho_ratio = 1 + alpha * (temp_Fe - T_ref);
    Kc = Kc_20 / rho_ratio;  % 涡流损耗系数与电阻率成反比
    
    % 可选：磁滞损耗系数的温度修正（通常影响较小）
    % 可根据材料数据添加 Kh 的温度相关性
    % Kh = Kh_20 * (1 - gamma * (temperature - T_ref)); 
    density = 7650; % 硅钢片密度 [kg/m³]
    % 体积计算
    h_yoke_m = slot.yoke_height / 1000;
    % 更精确的计算方法
    V_yoke = (pi/4 * (D_os^2 - (D_os - 2*h_yoke_m)^2)) * L;
    V_tooth = (pi/4*(D_os^2-D_is^2)*L - slot.area/1e6*Q*L)  - V_yoke;

    % 将体积转换为质量 [kg]
    m_tooth = V_tooth * density;
    m_yoke = V_yoke * density;

    % 损耗计算（修正后的Bertotti模型，考虑温度影响）
    P_tooth = ( Kh * f * (B_t^beta) + Kc * (f * B_t)^2 + Ke * (f * B_t)^1.5 ) * m_tooth;
    P_yoke  = ( Kh * f * (B_y^beta) + Kc * (f * B_y)^2 + Ke * (f * B_y)^1.5 ) * m_yoke;

    P_fe = P_tooth + P_yoke;

%     % 可选：输出温度修正信息（调试用）
%     fprintf('温度: %.1f°C, 电阻率比例: %.3f, 涡流系数: %.2e\n', ...
%             temperature, rho_ratio, Kc);
end