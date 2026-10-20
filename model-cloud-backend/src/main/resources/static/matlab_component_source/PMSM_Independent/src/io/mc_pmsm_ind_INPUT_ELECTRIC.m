function pmsm_input = mc_pmsm_ind_INPUT_ELECTRIC(filename, design_sheet)
%mc_pmsm_ind_INPUT_ELECTRIC 从默认或任务快照Excel构造PMSM设计输入。
%   mc_pmsm_ind_INPUT_ELECTRIC()保持原默认配置行为。
%   mc_pmsm_ind_INPUT_ELECTRIC(filename)读取指定配置的50kW工作表。
%   mc_pmsm_ind_INPUT_ELECTRIC(filename, design_sheet)读取指定设计工作表。

project_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
default_file = fullfile(project_root, 'input', 'pmsm input.xlsx');
if nargin < 1 || isempty(filename)
    filename = default_file;
end
if nargin < 2 || isempty(design_sheet)
    design_sheet = "50kW";
end
filename = char(string(filename));
design_sheet = char(string(design_sheet));

if ~isfile(filename)
    error('PMSM:InputElectric:FileNotFound', '电机配置文件不存在：%s', filename);
end
available_sheets = string(sheetnames(filename));
required_sheets = [string(design_sheet), "Material"];
for index = 1:numel(required_sheets)
    if ~any(available_sheets == required_sheets(index))
        error('PMSM:InputElectric:MissingSheet', ...
            '电机配置缺少工作表：%s', required_sheets(index));
    end
end

data = readtable(filename, Sheet=design_sheet, VariableNamingRule="preserve");
require_columns(data, {'variables', 'value', 'opt', 'min', 'max'}, design_sheet);
required_variables = {
    'voltage_phase','voltage_line','N_phase','pole_pairs','arc_factor', ...
    'carter_factor','N_slot','slot_pitch','N_cs','A_s','h_airgap','B_g', ...
    'X_tooth','X_yoke','B_tooth','B_yoke','a','J_max','slot_fill', ...
    'cos_phi','K_w','K_stack','rho_Cu','alpha_Cu','X_stator','X_length', ...
    'XC_cgv','XH_cgv','X_rotor','temperature_limit','magnet','cooling'};

variable_column = string(data.("variables"));
if numel(unique(variable_column)) ~= numel(variable_column)
    error('PMSM:InputElectric:DuplicateVariable', '设计工作表中存在重复变量名。');
end
missing_variables = setdiff(string(required_variables), variable_column);
if ~isempty(missing_variables)
    error('PMSM:InputElectric:MissingVariable', ...
        '设计工作表缺少变量：%s', strjoin(missing_variables, ', '));
end

exclude_groups = {
    {'N_cs', 'A_s'};
    {'X_tooth', 'B_tooth'};
    {'X_yoke', 'B_yoke'};
};
all_opt_vars = {};
all_min_vals = [];
all_max_vals = [];
for index = 1:height(data)
    variable_name = char(variable_column(index));
    if ~isvarname(variable_name)
        error('PMSM:InputElectric:InvalidVariable', ...
            '变量名不能作为MATLAB结构体字段：%s', variable_name);
    end
    variable_value = data.("value")(index);
    opt_value = data.("opt")(index);
    if ~isnumeric(variable_value) || ~isscalar(variable_value) || ~isfinite(variable_value)
        error('PMSM:InputElectric:InvalidValue', '变量%s的value必须是有限数值。', variable_name);
    end
    if ~ismember(opt_value, [0, 1])
        error('PMSM:InputElectric:InvalidOpt', '变量%s的opt必须为0或1。', variable_name);
    end
    if opt_value == 1
        minimum = data.("min")(index);
        maximum = data.("max")(index);
        if ~isfinite(minimum) || ~isfinite(maximum) || minimum > maximum
            error('PMSM:InputElectric:InvalidRange', ...
                '变量%s的优化范围无效。', variable_name);
        end
        all_opt_vars{end + 1} = string(variable_name); %#ok<AGROW>
        all_min_vals(end + 1) = minimum; %#ok<AGROW>
        all_max_vals(end + 1) = maximum; %#ok<AGROW>
    end
    pmsm_input.(variable_name) = variable_value;
end

% 兼容原排除组语义：同一组出现多个优化变量时只保留首个。
for group_index = 1:numel(exclude_groups)
    group = string(exclude_groups{group_index});
    matches = find(ismember(string(all_opt_vars), group));
    if numel(matches) > 1
        remove_indexes = matches(2:end);
        all_opt_vars(remove_indexes) = [];
        all_min_vals(remove_indexes) = [];
        all_max_vals(remove_indexes) = [];
    end
end

pmsm_input.optimal.design_parameters = all_opt_vars;
pmsm_input.optimal.range = [all_min_vals; all_max_vals];
pmsm_input.thermal.temp_variables = {'temp_Fe', 'temp_Cu'};
pmsm_input.thermal.temp_values = ...
    pmsm_input.temperature_limit * ones(2, 1);

material_data = readtable(filename, Sheet="Material", VariableNamingRule="preserve");
require_columns(material_data, ...
    {'material','thermal_conductivity (W/(mK))','density (kg/m^3)', ...
     'B_r(T)','H_cj(kA/m)','description'}, 'Material');
if isempty(material_data)
    error('PMSM:InputElectric:EmptyMaterial', 'Material工作表不能为空。');
end
pmsm_input.material.data = material_data;
end

function require_columns(table_value, required_columns, sheet_name)
actual_columns = string(table_value.Properties.VariableNames);
missing_columns = setdiff(string(required_columns), actual_columns);
if ~isempty(missing_columns)
    error('PMSM:InputElectric:MissingColumn', ...
        '工作表%s缺少列：%s', sheet_name, strjoin(missing_columns, ', '));
end
end
