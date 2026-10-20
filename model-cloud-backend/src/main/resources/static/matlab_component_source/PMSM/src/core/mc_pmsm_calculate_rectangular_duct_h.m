function h = mc_pmsm_calculate_rectangular_duct_h(velocity, width, height, fluid_props)
% 计算矩形管路对流换热系数
% 输入:
%   velocity - 流体速度 (m/s)
%   width - 矩形宽度 (m)
%   height - 矩形高度 (m)
%   fluid_props - 流体属性结构体，包含:
%       .rho - 密度 (kg/m³)
%       .mu - 动力粘度 (Pa·s)
%       .cp - 比热容 (J/kg·K)
%       .k - 导热系数 (W/m·K)
%       .Pr - 普朗特数
%   wall_temp - 壁面温度 (K)
%   bulk_temp - 流体整体温度 (K)
% 输出:
%   h - 对流换热系数 (W/m²·K)

    % 计算水力直径
    Dh = 2 * (width * height) / (width + height);
    
    % 计算雷诺数
    Re = fluid_props.rho * velocity * Dh / fluid_props.mu;
    
    % 根据流态选择关联式
    if Re < 2300
        % 层流
        h = laminar_rectangular_duct(Re, fluid_props.Pr, fluid_props.k, Dh, width/height);
    else
        % 湍流
        h = turbulent_rectangular_duct(Re, fluid_props.Pr, fluid_props.k, Dh);
    end
end
function h = laminar_rectangular_duct(Re, Pr, k, Dh, aspect_ratio)
% 矩形管路层流对流换热系数计算
% 使用Shah-London关联式

    % 充分发展流努塞尔数常数
    % 对于矩形截面，Nu常数取决于宽高比
    if aspect_ratio >= 1
        % 根据宽高比插值Nu常数
        aspect_ratios = [1, 1.5, 2, 3, 4, 8, inf];
        nu_constants = [3.61, 3.73, 4.12, 4.79, 5.33, 6.49, 8.23];
        Nu_inf = interp1(aspect_ratios, nu_constants, aspect_ratio, 'linear', 8.23);
    else
        % 如果宽高比<1，取倒数
        Nu_inf = laminar_rectangular_duct(Re, Pr, k, Dh, 1/aspect_ratio);
    end
    
    % 入口效应修正 (Gnielinski关联式)
    L = 1.0; % 假设管长1m，实际应根据具体几何确定
    Gz = (Dh / L) * Re * Pr;  % 格雷茨数
    
    if Gz > 100
        % 充分发展流
        Nu = Nu_inf;
    else
        % 考虑入口效应
        Nu = Nu_inf + (0.039 * Gz^(2/3)) / (1 + 0.02 * Gz^(-2/3));
    end
    
    % 普朗特数修正
    if Pr > 0.7
        Nu = Nu * (Pr/0.7)^0.11;
    else
        Nu = Nu * (Pr/0.7)^0.01;
    end
    
    % 计算对流换热系数
    h = Nu * k / Dh;
end
function h = turbulent_rectangular_duct(Re, Pr, k, Dh)
% 矩形管路湍流对流换热系数计算
% 使用Dittus-Boelter或Gnielinski关联式

    if Re < 10000
        % Dittus-Boelter关联式 (加热情况)
        Nu = 0.023 * Re^0.8 * Pr^0.4;
    else
        % Gnielinski关联式 (更精确，适用于更广的Re范围)
        f = (0.79 * log(Re) - 1.64)^-2;  % 摩擦因子
        Nu = (f/8) * (Re - 1000) * Pr / (1 + 12.7 * sqrt(f/8) * (Pr^(2/3) - 1));
    end
    
    
    % 矩形截面形状修正
    aspect_ratio_correction = 1.0; % 对于湍流，矩形修正较小，通常取1.0
    
    Nu = Nu * aspect_ratio_correction;
    
    % 计算对流换热系数
    h = Nu * k / Dh;
end