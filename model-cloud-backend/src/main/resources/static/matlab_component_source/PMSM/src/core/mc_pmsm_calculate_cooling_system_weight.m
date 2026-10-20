function cooling_weight = mc_pmsm_calculate_cooling_system_weight(motor_dims, motor_loss)
% 简化版水冷系统重量计算
% 输入:
%   motor_dims - 电机尺寸 [长度(m), 直径(m)]
%   motor_loss - 电机损耗 (kW)
% 输出:
%   cooling_weight - 各组件重量结构体

    %% 参数设置
    % 材料密度 (kg/m³)
    density.aluminum = 2700;    % 水冷套材料
    density.coolant = 1000;     % 冷却液
    density.pipe = 1400;        % 管路材料
    
    % 设计参数
    params.jacket_thickness = 0.005;      % 水冷套壁厚 5mm
    params.channel_depth = 0.008;         % 冷却水道深度 8mm
    params.pipe_length = 3.0;             % 总管路长度 3m
    params.pipe_diameter = 0.015;         % 管路内径 15mm
    params.pipe_wall = 0.003;             % 管路壁厚 3mm
    params.reservoir_capacity = 0.002;    % 膨胀水箱容量 2L
    
    %% 1. 冷却液流量计算
    delta_T = 10;  % 设计温升 10°C
    cp_water = 4180;  % 水的比热容 J/(kg·K)
    
    coolant_flow = (motor_loss * 1000) / (cp_water * delta_T);  % kg/s
    flow_lpm = coolant_flow * 60;  % L/min
    
    fprintf('电机损耗: %.2f kW\n', motor_loss);
    fprintf('所需冷却液流量: %.2f L/min\n\n', flow_lpm);
    
    %% 2. 水冷套重量计算
    L = motor_dims(1);      % 电机长度
    D = motor_dims(2);      % 电机直径
    
    % 水冷套表面积
    jacket_area = pi * D * L;
    
    % 水冷套体积 (壁厚 + 水道深度)
    jacket_volume = jacket_area * (params.jacket_thickness + params.channel_depth);
    jacket_weight = jacket_volume * density.aluminum;
    
    fprintf('水冷套重量: %.2f kg\n', jacket_weight);
    
    %% 3. 冷却液重量计算
    % 水冷套内冷却液体积 (考虑实际流通面积)
    jacket_coolant_vol = jacket_area * params.channel_depth * 0.7;
    
    % 管路内冷却液体积
    pipe_coolant_vol = pi * (params.pipe_diameter/2)^2 * params.pipe_length;
    
    % 总冷却液体积
    total_coolant_vol = jacket_coolant_vol + pipe_coolant_vol + params.reservoir_capacity;
    coolant_weight = total_coolant_vol * density.coolant;
    
    fprintf('冷却液重量: %.2f kg\n', coolant_weight);
    
    %% 4. 管路系统重量计算
    pipe_outer_dia = params.pipe_diameter + 2 * params.pipe_wall;
    pipe_volume = pi * ((pipe_outer_dia/2)^2 - (params.pipe_diameter/2)^2) * params.pipe_length;
    pipe_weight = pipe_volume * density.pipe;
    
    % 接头重量估算
    fitting_weight = ceil(params.pipe_length / 0.5) * 0.05;  % 每0.5m一个接头
    
    total_pipe_weight = pipe_weight + fitting_weight;
    fprintf('管路系统重量: %.2f kg\n', total_pipe_weight);
    
    %% 5. 水泵重量计算
    % 估算所需扬程 (基于经验)
    required_head = 5 + motor_loss * 0.2;  % 米水柱
    
    % 水泵功率估算
    pump_power = (coolant_flow * 9.81 * required_head) / 0.6;  % W
    
    % 水泵重量经验公式
    pump_weight = 0.8 + pump_power * 0.002;
    
    fprintf('水泵重量: %.2f kg\n', pump_weight);
    
    %% 6. 总重量汇总
    total_weight = jacket_weight + coolant_weight + total_pipe_weight + pump_weight;
    
    fprintf('\n=== 冷却系统总重量: %.2f kg ===\n', total_weight);
    
    %% 7. 输出结果
    cooling_weight = struct(...
        'total', total_weight, ...
        'jacket', jacket_weight, ...
        'coolant', coolant_weight, ...
        'piping', total_pipe_weight, ...
        'pump', pump_weight, ...
        'flow_rate', flow_lpm, ...
        'pump_power', pump_power);
    
    %% 8. 简单可视化
    figure('Position', [200, 200, 800, 600]);
    
    % 重量分布
    subplot(2,2,1);
    weights = [jacket_weight, coolant_weight, total_pipe_weight, pump_weight];
    labels = {'水冷套', '冷却液', '管路', '水泵'};
    pie(weights, labels);
    title('重量分布');
    
    % 参数显示
    subplot(2,2,2);
    text(0.1, 0.9, sprintf('总重量: %.1f kg', total_weight), 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.7, sprintf('流量: %.1f L/min', flow_lpm), 'FontSize', 10);
    text(0.1, 0.6, sprintf('水泵功率: %.0f W', pump_power), 'FontSize', 10);
    text(0.1, 0.5, sprintf('电机损耗: %.1f kW', motor_loss), 'FontSize', 10);
    axis off;
    title('系统参数');
    
    % 重量柱状图
    subplot(2,2,3);
    bar(weights);
    set(gca, 'XTickLabel', labels);
    ylabel('重量 (kg)');
    title('各组件重量');
    grid on;
    
    % 电机尺寸示意图
    subplot(2,2,4);
    rectangle('Position', [-D/2, 0, D, L], 'FaceColor', [0.8 0.8 0.8]);
    rectangle('Position', [-D/2-0.01, -0.02, D+0.02, L+0.04], ...
              'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.3);
    axis equal;
    xlim([-D, D]*0.7);
    ylim([-0.1, L+0.1]);
    title('电机+水冷套示意');
    xlabel('直径方向');
    ylabel('长度方向');
end

%% 使用示例函数
function run_examples()
    % 示例1: 小型电机
    fprintf('=== 示例1: 小型电机 ===\n');
    motor1_dims = [0.2, 0.15];  % [长度, 直径] (m)
    motor1_loss = 2.5;          % 损耗 (kW)
    cooling1 = simple_cooling_weight_calc(motor1_dims, motor1_loss);
    
    fprintf('\n=== 示例2: 中型电机 ===\n');
    motor2_dims = [0.4, 0.25];  % [长度, 直径] (m)
    motor2_loss = 8.0;          % 损耗 (kW)
    cooling2 = simple_cooling_weight_calc(motor2_dims, motor2_loss);
    
    fprintf('\n=== 示例3: 大型电机 ===\n');
    motor3_dims = [0.6, 0.35];  % [长度, 直径] (m)
    motor3_loss = 15.0;         % 损耗 (kW)
    cooling3 = simple_cooling_weight_calc(motor3_dims, motor3_loss);
    
    % 对比分析
    figure;
    motors = {'小型', '中型', '大型'};
    total_weights = [cooling1.total, cooling2.total, cooling3.total];
    bar(total_weights);
    set(gca, 'XTickLabel', motors);
    ylabel('总重量 (kg)');
    title('不同电机尺寸的冷却系统重量对比');
    grid on;
end

% 主函数调用
% cooling_weight = simple_cooling_weight_calc([0.3, 0.2], 5.0);

% 运行示例
% run_examples();