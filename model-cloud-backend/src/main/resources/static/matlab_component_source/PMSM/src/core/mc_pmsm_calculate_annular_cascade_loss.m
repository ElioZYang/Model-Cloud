function total_pressure_loss = mc_pmsm_calculate_annular_cascade_loss(...
    V, D_inner, D_outer, ...
    N_blade,blade_height,tip_clearance, ...
    chord_length,Re, Ma, ...
    flow_angle, stagger_angle,rho_in)
% 计算环形叶栅的总压损失
% 简化的工程经验公式方法


    %% 基本参数计算
    % 平均直径
    D_mean = (D_inner + D_outer) / 2;
    
    % 栅距
    pitch = pi * D_mean / N_blade;
    
    % 稠度
    solidity = chord_length / pitch;
    
    % 展弦比
    aspect_ratio = blade_height / chord_length;
    
    % 气流折转角
    turning_angle = abs(flow_angle - stagger_angle);

    %% 基础损失系数计算 (Soderberg方法)
    % 型面损失
    profile_loss_coeff = 0.04 + 0.06 * (turning_angle / 100)^2;
    
    % 二次流损失
    lift_coeff = 2 * (turning_angle * pi / 180) / solidity;
    secondary_loss_coeff = 0.038 + 0.41 * tanh(1.2 * turning_angle / 25) * ...
                          (lift_coeff^2) / aspect_ratio;

    %% 各种修正因子
    % 雷诺数修正
    if Re < 2e5
        Re_correction = (2e5 / Re)^0.2;
    else
        Re_correction = 1.0;
    end
    
    % 马赫数修正
    if Ma < 0.7
        Ma_correction = 1.0;
    else
        Ma_correction = 1.0 + 0.3 * (Ma - 0.7);
    end
    
    % 稠度修正
    if solidity < 0.8
        solidity_correction = 1.0 + 0.3 * (0.8 - solidity);
    elseif solidity > 1.5
        solidity_correction = 1.0 + 0.2 * (solidity - 1.5);
    else
        solidity_correction = 1.0;
    end
    
    % 展弦比修正
    if aspect_ratio < 1.5
        aspect_correction = 1.0 + 0.1 * (1.5 - aspect_ratio);
    else
        aspect_correction = 1.0;
    end
    
    % 叶顶间隙损失
    if tip_clearance > 0
        clearance_ratio = tip_clearance / blade_height;
        clearance_loss = 0.5 * clearance_ratio * lift_coeff^2;
    else
        clearance_loss = 0;
    end

    %% 总损失系数计算
    total_loss_coeff = (profile_loss_coeff + secondary_loss_coeff + clearance_loss) * ...
                      Re_correction * Ma_correction * solidity_correction * aspect_correction;
    
    % 限制损失系数在合理范围内
    total_loss_coeff = max(min(total_loss_coeff, 0.15), 0.02);

    %% 总压损失计算
    % 进口动压
    dynamic_pressure = 0.5 * rho_in * V^2;
    
    % 总压损失
    total_pressure_loss = total_loss_coeff * dynamic_pressure;

end

%% 示例使用函数
function example_usage()
    % 示例：计算典型环形叶栅损失
    
    V = 180;           % 进口速度 m/s
    D_inner = 0.45;    % 内径 m
    D_outer = 0.55;    % 外径 m
    T_in = 600;        % 进口总温 K
    P_in = 500e3;      % 进口总压 Pa
    N_blade = 48;      % 叶片数
    blade_height = 0.05; % 叶高 m
    chord_length = 0.03; % 弦长 m
    flow_angle = 45;   % 气流角 度
    stagger_angle = 25; % 安装角 度
    Re = 3e5;          % 雷诺数
    Ma = 0.5;          % 马赫数
    tip_clearance = 0.001; % 叶顶间隙 m
    
    loss = mc_pmsm_calculate_annular_cascade_loss(V, D_inner, D_outer, T_in, P_in, ...
                N_blade, blade_height, chord_length, flow_angle, stagger_angle, ...
                Re, Ma, tip_clearance);
    
    fprintf('示例计算结果: 总压损失 = %.1f Pa\n', loss);
end
