function [dTdt,T_thermal_balance] = mc_pmsm_ind_thermal_balance_solver(R, C, P, T, LM1, LM2)
% 处理热容无限大（温度给定节点）的向量化实现
%
% 输入参数：
%   R - N×N热阻矩阵
%   C - N×1热容向量，Inf表示温度给定节点
%   P - N×1功率向量
%   T - N×1温度向量
%
% 输出参数：
%   A - 约化后的系统矩阵
%   B - 约化后的输入向量  
%   dTdt - 完整的温升率向量（温度给定节点为0）
%   T_reduced - 约化系统的温度向量

    [A, B] = mc_pmsm_ind_simplify_thermal_network(R, C, P, LM1, LM2);
    dTdt = A * T + B;
        % 提取子矩阵
    A21 = A(2:end, 1);      % A 的第一列（去掉第一个元素）
    A22 = A(2:end, 2:end);  % A 的右下角 (n-1)×(n-1) 子矩阵
    B2 = B(2:end);          % B 的后面 n-1 个元素
    
    % 求解 T2 = -A22^(-1) * (A21 * T1 + B2)
    T_thermal_balance = -A22 \ (A21 * T(1) + B2);
end