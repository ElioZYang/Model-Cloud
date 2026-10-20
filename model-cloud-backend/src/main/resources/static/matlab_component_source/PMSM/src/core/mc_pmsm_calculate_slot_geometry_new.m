%% 槽形计算子函数
function [slot,D_os] = mc_pmsm_calculate_slot_geometry_new...
    (D_is,D_os,A_slot_min, ...
Q,p,k_fe,slot_fill, ...
X_tooth,X_yoke,...
B_g,B_tooth,B_yoke)
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


    % 1. 计算基本几何量
    t_s = pi * D_is / Q;          % 齿距 [m]
    % 3. 确定槽口宽度 (基于工艺和齿部磁密)
    b_open = .2 * t_s;
    theta=2*pi/Q;
    h_slot_open = b_open;
    
    % 4. 计算齿宽 (核心约束1: 齿部磁密)
    if X_tooth>0
    b_tooth=X_tooth*t_s;
    B_tooth = (B_g * t_s) / (b_tooth * k_fe);
    else
    b_tooth=(B_g * t_s) / (B_tooth * k_fe);
    end
    % 5. 计算所需轭部高度 (核心约束2: 轭部磁密)
    tau_p = pi * D_is / (2 * p); % 极距, 假设极数包含在类型名中，如'SPM4'
    if X_yoke>0
    h_yoke=X_yoke*D_is/2;
    B_yoke=B_g * tau_p / (2 * h_yoke  * k_fe);
    else
    h_yoke = B_g * tau_p / (2 * B_yoke  * k_fe); % 所需最小轭高 [m]
    end
    % 防止槽面积不足
    a=.5*theta;
    b=theta*(D_is/2+h_slot_open)-b_tooth;
    c=-A_slot_min;
    h_min=(-b+(b^2-4*a*c)^.5)/2/a;
    D_os_min=D_is+(h_slot_open+h_min+h_yoke)*2;
    D_os=max(D_os,D_os_min);
    h_total=(D_os-D_is)/2;
    h_slot=h_total-h_yoke;
    h_slot_body=h_slot-h_slot_open;
    % 7. 定义槽身部分 (梯形)
    % 假设槽身高度 = 总槽深 - 槽口高度
    % 梯形槽底宽
    b_bottom = pi*(D_is+2*h_slot)/Q-b_tooth*(D_is+2*h_slot)/(D_is+h_slot);
    % 8. 计算槽净面积 (槽口矩形 + 槽身梯形)
    A_slot_open = ((D_is/2+h_slot_open)^2-D_is^2/4)*b_open/D_is;
    A_slot_body = ((D_is/2+h_slot)^2-(D_is/2+h_slot_open)^2)*b_bottom/(D_is+2*h_slot);
%     slot_fill=slot_fill_max*A_slot_req/A_slot_body;
    A_slot = A_slot_open + A_slot_body;
    
    % 9. 组装输出
    slot = struct(...
        'opening_width',  b_open * 1000,      ... % [mm]
        'opening_height', h_slot_open * 1000,      ... % [mm]
        'body_depth',     h_slot_body * 1000, ... % [mm]
        'total_depth',    h_slot * 1000, ... % [mm]
        'bottom_width',   b_bottom * 1000,    ... % [mm]
        'yoke_height',    h_yoke * 1000,  ... % [mm]
        'area_body', A_slot_body * 1e6,...
        'area',           A_slot * 1e6,       ... % [mm²]
        'tooth_width',    b_tooth * 1000,     ... % [mm]
        'tooth_flux_density', B_tooth,        ... % [T]
        'yoke_flux_density', B_yoke ,  ... % [T]
        'slot_fill',slot_fill, ...
        'slot_number',Q);

%     valid = true;
%     fprintf('槽形设计成功。齿部磁密: %.2f T, 轭部高度: %.1f mm, 槽面积: %.1f mm²\n', ...
%             B_tooth, h_yoke_req*1000, A_slot*1e6);
end