%% 槽形计算子函数
function [slot, valid] = mc_pmsm_calculate_slot_geometry(D_is, D_os, L, Q, p, ...
    B_g, B_tooth_max, B_yoke_max, ...
    b_open_factor,h_open_factor,h_body_factor,b_bottom_factor)
    % 优化版槽形设计函数
    % 输入:
    %   D_is, D_os: 定子内/外径 [m]
    %   Q: 槽数
    %   B_g: 气隙磁密 [T]
    %   B_tooth_max, B_yoke_max: 齿/轭部最大允许磁密 [T]
    %   L: 铁芯长度 [m]
    %   pole_type: 磁极类型 ('SPM', 'IPM', 'VPM')
    % 输出:
    %   slot: 槽形参数结构体
    %   valid: 设计是否成功的标志

    % 常数定义
    k_fe = 0.97; % 铁芯叠压系数

    % 1. 计算基本几何量
    t_s = pi * D_is / Q;          % 齿距 [m]
    h_stator = (D_os - D_is) / 2; % 最大可能槽深 [m]

    % 3. 确定槽口宽度 (基于工艺和齿部磁密)
    b_open = b_open_factor * t_s;
    % 4. 计算齿宽 (核心约束1: 齿部磁密)
    b_tooth = t_s - b_open; % 实际齿宽 [m]
    B_tooth = (B_g * t_s) / (b_tooth * k_fe); % 校验齿部磁密 [T]
    % 5. 计算所需轭部高度 (核心约束2: 轭部磁密)
    tau_p = pi * D_is / (2 * p); % 极距, 假设极数包含在类型名中，如'SPM4'
    Phi_p = B_g * tau_p * L; % 每极磁通幅值 [Wb]
    h_yoke_req = Phi_p / (2 * B_yoke_max * L * k_fe); % 所需最小轭高 [m]

    % 6. 计算可用槽深
    h_slot_available = h_stator - h_yoke_req;
    h_slot_open = h_open_factor * h_slot_available;
    valid=(B_tooth<=B_tooth_max&&h_slot_available>0);
    % 7. 定义槽身部分 (梯形)
    % 假设槽身高度 = 总槽深 - 槽口高度
    h_slot_body = (h_slot_available - h_slot_open)*h_body_factor;
    h_slot=h_slot_body+h_slot_open;
    h_yoke=h_stator-h_slot;
    % 梯形槽底宽
    b_bottom = b_bottom_factor*t_s*(D_is+2*h_slot)/D_is;
    % 8. 计算槽净面积 (槽口矩形 + 槽身梯形)
    A_slot_open = ((D_is/2+h_slot_open)^2-D_is^2/4)*b_open/D_is;
    A_slot_body = ((D_is/2+h_slot)^2-(D_is/2+h_slot_open)^2)*b_bottom/(D_is+2*h_slot);
    A_slot = A_slot_open + A_slot_body;


    % 9. 组装输出
    slot = struct(...
        'opening_width',  b_open * 1000,      ... % [mm]
        'opening_height', h_slot_open * 1000,      ... % [mm]
        'body_depth',     h_slot_body * 1000, ... % [mm]
        'total_depth',    h_slot * 1000, ... % [mm]
        'bottom_width',   b_bottom * 1000,    ... % [mm]
        'yoke_height',    h_yoke * 1000,  ... % [mm]
        'area',           A_slot * 1e6,       ... % [mm²]
        'tooth_width',    b_tooth * 1000,     ... % [mm]
        'tooth_flux_density', B_tooth,        ... % [T]
        'yoke_flux_density_est', B_yoke_max   ... % [T]
    );

%     valid = true;
%     fprintf('槽形设计成功。齿部磁密: %.2f T, 轭部高度: %.1f mm, 槽面积: %.1f mm²\n', ...
%             B_tooth, h_yoke_req*1000, A_slot*1e6);
end