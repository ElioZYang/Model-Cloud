function[pmsm_input]=INPUT_ELECTRIC
filename = 'pmsm input.xlsx';
data = readtable(filename, Sheet="50kW",VariableNamingRule="preserve");
% 初始化空向量
variable_names = {};
min_values = [];
max_values = [];
% 定义需要排除的变量组
exclude_groups = {
    {'N_cs', 'A_s'},      % 组1: 如果同时出现，只保留第一个
    {'X_tooth', 'B_tooth'}, % 组2: 如果同时出现，只保留第一个  
    {'X_yoke', 'B_yoke'}    % 组3: 如果同时出现，只保留第一个
};
% 第一遍：收集所有opt=1的变量
all_opt_vars = {};
all_min_vals = [];
all_max_vals = [];
for i = 1:height(data)
    var_name = data{i, 1}{1};  % 获取变量名（第一列）
    var_value = data{i, 2};    % 获取变量值（第二列）
    
    % 处理不同类型的值
    if istable(var_value)
        % 如果是表格，转换为数组
        var_value = table2array(var_value);
    end
    varname1=string(var_name);
    if data.opt(i) == 1
        all_opt_vars{end+1} = var_name;
        all_min_vals(end+1) = data.min(i);
        all_max_vals(end+1) = data.max(i);
    end
    % 将变量添加到结构体
    pmsm_input.(var_name) = var_value;
end
pmsm_input.optimal.design_parameters=all_opt_vars;
pmsm_input.optimal.range=[all_min_vals;all_max_vals];
temp_variables={'temp_Fe','temp_Cu'};
temp_values=pmsm_input.temperature_limit*ones(length(temp_variables),1);
pmsm_input.thermal.temp_variables=temp_variables;
pmsm_input.thermal.temp_values=temp_values;
data = readtable(filename,Sheet="Material",VariableNamingRule="preserve");
pmsm_input.material.data=data;