function [thermal_efficiency, W_net, Q_in] = mc_pmsm_calculate_teps_thermal_efficiency(PRC, EFFC, PRT, EFFT, T0, EB, HU, E_motor, T_amb, P_amb)
    % 计算涡轴发动机整体热效率
    %
    % 输入参数:
    %   PRC: 压气机压比
    %   EFFC: 压气机绝热效率
    %   PRT: 涡轮膨胀比  
    %   EFFT: 涡轮绝热效率
    %   T0: 涡轮前温度 (K)
    %   EB: 燃烧效率
    %   HU: 燃料热值 (J/kg)
    %   E_motor: 发电效率
    %   T_amb: 环境温度 (K)
    %   P_amb: 环境压力 (Pa)
    %
    % 输出参数:
    %   thermal_efficiency: 整体热效率
    %   W_net: 净输出功 (J/kg)
    %   Q_in: 输入热量 (J/kg)
    
    % 常数定义
    Cp = 1005;      % 空气定压比热容
    Cpg = 1150;     % 燃气定压比热容  
    gamma = 1.4;    % 空气比热容比
    gammag = 1.33;  % 燃气比热容比
    
    %% 压气机计算
    % 压气机出口温度
    T2_ideal = T_amb * PRC^((gamma-1)/gamma);
    T2 = T_amb + (T2_ideal - T_amb) / EFFC;
    
    % 压气机耗功
    W_compressor = Cp * (T2 - T_amb);
    
    %% 燃烧室计算
    % 燃烧室出口温度 = 涡轮前温度 T0
    % 燃烧室进口温度 = 压气机出口温度 T2
    
    % 燃料空气比计算 (基于能量平衡)
    FAR = (Cpg * T0 - Cp * T2) / (EB * HU - Cpg * T0);
    
    % 输入热量
    Q_in = FAR * HU * EB;
    
    %% 涡轮计算
    % 涡轮进口温度 = T0
    % 涡轮出口温度 (理想)
    T4_ideal = T0 / PRT^((gammag-1)/gammag);
    
    % 涡轮出口温度 (实际)
    T4 = T0 - EFFT * (T0 - T4_ideal);
    
    % 涡轮输出功
    W_turbine = Cpg * (T0 - T4);
    
    %% 功率平衡与效率计算
    % 涡轮净功 (用于驱动压气机和附件)
    W_turbine_net = W_turbine - W_compressor;
    
    % 考虑发电效率的净电功输出
    W_electric = W_turbine_net * E_motor;
    
    % 整体热效率 (电功输出 / 燃料化学能输入)
    thermal_efficiency = W_electric / (FAR * HU);
    
    % 输出参数
    W_net = W_electric;
end