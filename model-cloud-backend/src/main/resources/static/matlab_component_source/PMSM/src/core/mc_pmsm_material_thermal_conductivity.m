function k = mc_pmsm_material_thermal_conductivity(material, t)
% mc_pmsm_material_thermal_conductivity - 计算PMSM材料的导热系数
% 输入:
%   material - PMSM材料名称，包括: 'air', 'windings', 'stator', 'rotor', 'magnet', 'liquid'
%   t - 热力学温度 (K)
% 输出:
%   k - 导热系数 (W/m·K)

% 输入参数验证
if nargin < 2
    error('需要提供材料名称和温度两个参数');
end

if ~ischar(material) && ~isstring(material)
    error('材料名称必须是字符串类型');
end

if t <= 0
    error('温度必须是正数');
end

% 将材料名称转换为小写以便不区分大小写
material = lower(char(material));

% 根据材料类型计算导热系数
switch material
    case 'air'
        % 空气导热系数 (W/m·K)，温度相关
        % 参考: 工程热物理手册
        k = 0.0241 + 7.8e-5 * (t - 273.15);
        
    case 'windings'
        % 绕组导热系数 (铜线+绝缘材料)
        % 参考: 电机设计手册
        k = 400 - 0.1 * (t - 293.15);  % 随温度升高略有下降
        
    case 'stator'
        % 定子铁芯导热系数 (硅钢片)
        % 参考: 电机设计手册
        if t < 400
            k = 40 - 0.02 * (t - 293.15);
        else
            k = 35 - 0.05 * (t - 400);
        end
        
    case 'rotor'
        % 转子铁芯导热系数
        % 参考: 电机设计手册
        k = 45 - 0.025 * (t - 293.15);
        
    case 'magnet'
        % 永磁体导热系数 (钕铁硼)
        % 参考: 永磁材料手册
        k = 9.0 - 0.01 * (t - 293.15);
        
    case 'liquid'
        % 冷却液导热系数 (乙二醇水溶液50%)
        % 参考: 传热学手册
        k = 0.38 + 2e-4 * (t - 293.15);
        
    otherwise
        error('不支持的材料类型。支持的材料: air, windings, stator, rotor, magnet, liquid');
end

% 确保导热系数不为负值
k = max(k, 1e-6);

end