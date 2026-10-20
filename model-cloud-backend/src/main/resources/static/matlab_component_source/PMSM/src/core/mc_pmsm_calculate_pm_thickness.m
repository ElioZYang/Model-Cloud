function [hm] = mc_pmsm_calculate_pm_thickness(D, L, g, ...
    Bg, Br, Hcj, kc, pole_pairs, pole_arc_ratio, slot_width, slot_depth)
% 直接求解永磁体厚度和漏磁系数的联立方程
%
% 输入参数：
%   D, L, g, Bg, Br, Hcj, kc - 永磁体厚度公式参数
%   pole_pairs, pole_arc_ratio - 极数和极弧系数
%   slot_width, slot_depth - 槽参数
%
% 输出参数：
%   hm - 永磁体厚度 (m)
%   kf - 漏磁系数
%   solutions - 求解详细信息

%% 常数定义
mu0 = 4 * pi * 1e-7;  % 真空磁导率

%% 计算中间几何参数
tau = pi * D / (2 * pole_pairs);          % 极距 (m)
bp = pole_arc_ratio * tau;                % 极弧宽度 (m)

%% 计算系数

% 基准厚度值
A = (Bg * g * kc) / (mu0 * Hcj);

% 漏磁路径系数
C1 = 2 / (tau - bp);      % 侧面漏磁系数
C2 = 2 / L;               % 端部漏磁系数  
C3 = slot_width / slot_depth; % 槽口漏磁系数

% 耦合系数
K = (g / bp) * (Bg / Br);

%% 构建二次方程系数
a = K * (C1 + C2);
b = 1 - (Bg / Br) - K * C3; 
c = -A;

det = b^2 - 4*a*c;

% 求根
hm = (-b + sqrt(det)) / (2*a);

end