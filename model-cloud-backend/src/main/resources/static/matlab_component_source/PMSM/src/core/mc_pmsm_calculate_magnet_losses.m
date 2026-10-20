%% 永磁体损耗计算
function [P_mag, mag_params] = mc_pmsm_calculate_magnet_losses(...
    p, D_ir,D_or, L_stack, gap, f, B_g, magnet_type, pole_type, n_rated)
    % 精确计算永磁体涡流损耗
    % 输入：
    %   p - 极对数
    %   D_rotor - 转子外径(m)
    %   L_stack - 铁芯长度(m)
    %   gap - 气隙长度(m)
    %   f - 电频率(Hz)
    %   B_g - 气隙磁密(T)
    %   magnet_type - 磁钢类型
    %   pole_type - 磁极类型
    %   n_rated - 额定转速(rpm)
    % 输出：
    %   P_mag - 总磁钢损耗(W)
    %   mag_params - 磁钢参数结构体
    
    %% 1. 磁钢几何参数计算
    switch lower(pole_type)
        case 'spm'
            % 表贴式磁钢
            mag_params.type = 'Surface-mounted';
            
            % 磁钢厚度 (基于气隙磁密计算)
            B_r = 1.2;  % 钕铁硼剩磁(T)
            mu_rec = 1.05; % 相对回复磁导率
            h_mag = (B_g * mu_rec * gap) / (B_r - B_g);
            h_mag = max(h_mag, 0.002); % 最小2mm
            
            % 包角优化 (经验公式)
            theta = 120 + 20*(B_g - 0.8); % 磁密越高包角越大
            
            % 磁钢体积
            R_ro = D_or/2;
            R_ri = R_ro - h_mag;
            V_mag_single = (theta/360) * pi * (R_ro^2 - R_ri^2) * L_stack;
            V_mag = 2*p * V_mag_single;
            
            % 分段策略
            if f > 300  % 高频时分段
                d_seg = min(ceil(f/100), 5);
            else
                d_seg = 1;
            end
            
            % 存储参数
            mag_params.magnet_type=magnet_type;
            mag_params.thickness = h_mag * 1000; % mm
            mag_params.arc_angle = theta; % deg
            mag_params.volume = V_mag; % m³
            mag_params.segments = d_seg;
            
        case {'ipm', 'vipm'}
            % 内置式磁钢
            mag_params.type = 'Interior';
            
            % 磁钢厚度 (基于转子尺寸)
            h_rotor = (D_or - D_ir)/2; % 转子径向厚度
            h_mag = 0.15 * h_rotor;
            
            % 磁钢宽度
            tau_p = pi * D_or / (2*p); % 极距
            W_mag = 0.7 * tau_p;
            
            % V型特殊处理
            if strcmpi(pole_type, 'vipm')
                alpha = 45; % V型夹角
                h_mag = h_mag * 0.9;
                W_mag = W_mag * 0.8;
            else
                alpha = 0;
            end
            
            % 磁钢体积
            V_mag_single = W_mag * h_mag * L_stack;
            V_mag = 2*p * V_mag_single;
            
            % 分段策略 (内置式通常不分段)
            d_seg = 1;
            
            % 存储参数
            mag_params.magnet_type=magnet_type;
            mag_params.thickness = h_mag * 1000; % mm
            mag_params.width = W_mag * 1000; % mm
            mag_params.angle = alpha; % deg (仅VIPM有效)
            mag_params.volume = V_mag; % m³
            mag_params.segments = d_seg;
            
        otherwise
            error('未知磁极类型: %s', pole_type);
    end
    
    %% 2. 材料特性
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
    
    %% 3. 损耗计算 (考虑谐波和分段效应)
    % 基波损耗
    P_base = k_loss * (f/100)^2 * (B_g/0.8)^2 * V_mag;
    
    % 谐波增强 (经验公式)
    harmonic_factor = 1 + 0.05*(f/100)^0.7;
    
    % 分段效应
        seg_factor = 1/sqrt(d_seg);
    
    % 高速修正 (>8000rpm)
    if n_rated > 8000
        speed_factor = 1 + 0.001*(n_rated/1000)^1.5;
    else
        speed_factor = 1.0;
    end
    
    % 总损耗
    P_mag = P_base * harmonic_factor * seg_factor * speed_factor;
    
    %% 4. 存储额外参数
    mag_params.resistivity = rho;
    mag_params.loss_density = P_mag / V_mag; % W/m³
end