%% 永磁体损耗计算 - 非设计点
function [P_mag, mag_params] = mc_pmsm_calculate_magnet_losses_offdesign(...
    mag_params, f, B_g, n)
    % 基于设计点磁钢几何参数计算非设计点永磁体涡流损耗
    % 输入：
    %   design_mag_params - 设计点计算的磁钢参数结构体
    %   f - 非设计点电频率(Hz)
    %   B_g - 非设计点气隙磁密(T)
    %   magnet_type - 磁钢类型
    %   n_rated - 非设计点转速(rpm)
    % 输出：
    %   P_mag - 非设计点总磁钢损耗(W)
    %   mag_params - 更新后的磁钢参数结构体
    
    %% 1. 使用设计点的磁钢几何参数
    
    % 从设计点参数中提取关键几何信息
    V_mag = mag_params.volume;      % 磁钢总体积
    d_seg = mag_params.segments;    % 分段数
    d_seg=1;
    magnet_type = mag_params.magnet_type; % 磁铁类型
    %% 2. 材料特性 (与原代码相同)
    switch magnet_type
        case 'NdFeB'
            rho = 1.6e-6; % 电阻率(Ω·m)
            k_loss = 0.8;  % 损耗系数
        case 'SmCo'
            rho = 0.9e-6; % 电阻率(Ω·m)
            k_loss = 0.6;  % 损耗系数
        otherwise
            error('未知磁钢类型: %s', magnet_type);
    end
    
    %% 3. 损耗计算 (与原代码逻辑相同，仅输入参数变化)
    % 基波损耗 - 使用非设计点的频率和气隙磁密
    P_base = k_loss * (f/100)^2 * (B_g/0.8)^2 * V_mag;
    
    % 谐波增强 (经验公式)
    harmonic_factor = 1 + 0.05*(f/100)^0.7;
    
    % 分段效应
    seg_factor = 1/sqrt(d_seg);
    
    % 高速修正 (>8000rpm)
    if n > 8000
        speed_factor = 1 + 0.001*(n/1000)^1.5;
    else
        speed_factor = 1.0;
    end
    
    % 总损耗
    P_mag = P_base * harmonic_factor * seg_factor * speed_factor;
    
    %% 4. 更新参数结构体中的损耗相关参数
    mag_params.resistivity = rho;
    mag_params.loss_density = P_mag / V_mag; % 非设计点损耗密度 W/m³
end