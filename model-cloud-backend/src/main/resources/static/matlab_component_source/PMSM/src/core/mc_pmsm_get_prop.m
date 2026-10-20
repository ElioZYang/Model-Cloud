function[value]=mc_pmsm_get_prop(data,material_name,property_name)

% 获取材料属性值
% 输入：
%   data - 材料数据表
%   material_name - 材料名称，如 'steel', 'copper'
%   property_name - 属性名称，如 'thermal_conductivity', 'density', 'B_r', 'H_cj'
    
    % 找到材料所在行
    material_row = strcmp(data.material, material_name);
    
    if ~any(material_row)
        error('Material "%s" not found in table.', material_name);
    end
    
    % 构建完整的列名
    switch property_name
        case 'thermal_conductivity'
            full_col_name = 'thermal_conductivity (W/(m·K))';
        case 'density'
            full_col_name = 'density (kg/m^3)';
        case 'B_r'
            full_col_name = 'B_r(T)';
        case 'H_cj'
            full_col_name = 'H_cj(kA/m)';
        case 'description'
            full_col_name = 'description';
        otherwise
            error('Unknown property: %s', property_name);
    end
    
    % 获取属性值
    value = data.(full_col_name)(material_row);

end