function kf = mc_pmsm_calculate_leakage_factor(D, L, g, hm, ...
    pole_pairs, pole_arc_ratio, slot_width, slot_depth)
% 简化版漏磁系数计算

% 计算关键几何参数
tau = pi * D / (2 * pole_pairs);      % 极距
bp = pole_arc_ratio * tau;            % 极弧宽度

% 直接使用解析公式计算漏磁系数
kf = 1 + (g / bp) * (hm / ((tau - bp) / 2) + 2 * hm / L + slot_width / slot_depth);

end