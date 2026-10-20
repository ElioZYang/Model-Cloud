%% 气隙长度计算
function gap = mc_pmsm_calculate_airgap(D_is, n_rated, pole_type, B_g)
    % 输入：
    %   D_is - 定子内径(m)
    %   n_rated - 额定转速(rpm)
    %   pole_type - 磁极类型
    %   B_g - 气隙磁密(T)
    % 输出：
    %   gap - 计算气隙长度(m)
    
    % 1. 机械约束计算（考虑转子离心变形）
    mechanical_gap = 0.1 + 0.012*sqrt(D_is*1000) + ...  % 基础气隙(mm)
                   1e-5*(n_rated/1000)^2;               % 转速补偿项
    
    % 2. 电磁约束计算（考虑磁密饱和）
    electromagnetic_gap = (0.15 + 0.1*B_g) * ...       % 磁密补偿系数
                         (1 + 0.2*strcmpi(pole_type,'IPM')) * ... % 磁极类型补偿
                         D_is^(1/3);                   % 直径相关项
    
    % 3. 最终气隙取两者最大值并转换单位(m)
    gap = max(mechanical_gap, electromagnetic_gap) / 1000;
    
    % 气隙最小值限制(0.5mm)
    gap = max(gap, 0.0005); 
end