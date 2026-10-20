function[OUTPUT]=mc_pmsm_ind_PMSM_thermal_network(INPUT)
OUTPUT =INPUT;
pmsm_params=INPUT.pmsm_params;
cooling=pmsm_params.input.cooling;
if isfield(INPUT,'mode')
    mode=INPUT.mode;
else
    mode="design";
end
%% 输入参数
T   = INPUT.T;% 总温
P   = INPUT.P;% 总压
D   = INPUT.D;% 湿度
WA  = INPUT.WA;% 空气流量
EFF = INPUT.EFFH;% 热交换对主气流温升和压损的有效系数
FAR = INPUT.FAR;% 油气比

% 计算总质量流量
W = WA*(1+FAR);

if W<=0
    warning("no airflow")
end

% 计算绝热指数
K=mc_pmsm_ind_AE(T,FAR,D);

% 计算修正流量
WCOR=W*sqrt(T)/P;

% 将电机结果转换为热网络几何
thermal_geometry = mc_pmsm_ind_get_pmsm_geometry(pmsm_params);

% 提取固体热节点初始温度（°C -> K）。
temp_variables = pmsm_params.thermal.temp_variables;
temp_values = pmsm_params.thermal.temp_values;
T_Fe = temp_values(strcmpi(temp_variables,'temp_Fe'))+273;
T_Cu = temp_values(strcmpi(temp_variables,'temp_Cu'))+273;

% 材料导热系数 (W/(m·K))
material_data = pmsm_params.input.material.data;

% 创建材料属性查找函数
t_iso = 0.2*1e-3;
k_iso     = mc_pmsm_ind_get_prop(material_data,'iso', 'thermal_conductivity');
k_cu      = mc_pmsm_ind_get_prop(material_data,'copper', 'thermal_conductivity');
k_stator  = mc_pmsm_ind_get_prop(material_data,'steel', 'thermal_conductivity');
k_housing = mc_pmsm_ind_get_prop(material_data,'aluminum', 'thermal_conductivity');
k_cavity  = mc_pmsm_ind_get_prop(material_data,'cavity', 'thermal_conductivity');

k_slot = k_cu*thermal_geometry.slot_fill ...
    + k_cavity*(1-thermal_geometry.slot_fill);

%% 计算来流静参数
M_in0=W*(mc_pmsm_ind_GC(FAR,D)*T/K)^.5/thermal_geometry.Area/P;
fun=@(M_in) thermal_geometry.Area*M_in*mc_pmsm_ind_SV(T/(1+(K-1)/2*M_in^2),FAR,D)...
    *(P/T/mc_pmsm_ind_GC(FAR,D))*(1+(K-1)/2*M_in^2)^(1-K/(K-1))/W-1;
choke=fun(1);
if choke<0
    warning("hpcgv choke!")
    M_in=1;
    W  = W*(choke+1);
    WA = WA*(choke+1);
else
    M_in=fzero(fun,M_in0);
end

Ts_amb=T/(1+(K-1)/2*M_in^2);
Ps_amb=P/(1+(K-1)/2*M_in^2)^(K/(K-1));
Vel=M_in*mc_pmsm_ind_SV(Ts_amb,FAR,D);
rhos=Ps_amb/mc_pmsm_ind_GC(FAR,D)/Ts_amb;

if mode=="design"
    D_hpcgv=2*(thermal_geometry.Rho+thermal_geometry.H_cgv);
    OUTPUT.pmsm_params.geometry.AN=thermal_geometry.Area;
    OUTPUT.pmsm_params.geometry.hpcgv_OD=D_hpcgv*1000;
end

% 组装热节点的质量、损耗和初始温度。
node_data = struct( ...
    'copper_mass_kg',       pmsm_params.mass.copper, ...
    'stator_tooth_mass_kg', pmsm_params.mass.stator_tooth, ...
    'stator_yoke_mass_kg',  pmsm_params.mass.stator_yoke, ...
    'copper_loss_W',        pmsm_params.losses.copper, ...
    'total_loss_W',         pmsm_params.losses.total, ...
    'copper_temperature_K', T_Cu, ...
    'iron_temperature_K',   T_Fe);

% 组装流动状态和材料热物性，供三个冷却模型复用。
flow_state = struct( ...
    'T',     T, ...
    'FAR',   FAR, ...
    'W',     W, ...
    'Ts_amb',Ts_amb, ...
    'rhos',  rhos);

material_props = struct( ...
    'k_slot',   k_slot, ...
    'k_stator', k_stator, ...
    'k_housing',k_housing, ...
    'k_iso',    k_iso, ...
    't_iso',    t_iso);

switch cooling
    case 1
        thermal_network = mc_pmsm_ind_build_thermal_network_air( ...
            thermal_geometry,...
            flow_state,...
            material_props,...
            node_data);
    case 2
        thermal_network = mc_pmsm_ind_build_thermal_network_hpcgv( ...
            thermal_geometry,...
            flow_state,...
            material_props,...
            node_data);
    case 3
        thermal_network = mc_pmsm_ind_build_thermal_network_liquid( ...
            thermal_geometry,...
            flow_state,...
            material_props,...
            node_data);
        EFF=0;
end

R                 = thermal_network.R;
Q_Fe              = thermal_network.Q_Fe;
Q_Cu              = thermal_network.Q_Cu;
dT_air            = thermal_network.dT_air;
Re_cgv            = thermal_network.Re_cgv;
dT_pmsm_partial   = thermal_network.dT_pmsm_partial;
T_thermal_balance = thermal_network.T_thermal_balance;

T1 = T + dT_air * EFF;
%% 计算总压损失
switch mode
    case "design"   
        [dP] = mc_pmsm_ind_calculate_annular_cascade_loss(...
            Vel, ...
            2*thermal_geometry.Ro, ...
            2*thermal_geometry.Ro+2*thermal_geometry.H_cgv, ...
            thermal_geometry.N_slot,thermal_geometry.H_cgv,0, ...
            thermal_geometry.C_cgv,Re_cgv,M_in, ...
            0, 0, rhos);
        TPR=1-dP/P*EFF;
    case "offdesign"
        WCOR0=INPUT.WCOR;
        TPR0=INPUT.TPR;
        TPR=1-(1-TPR0)*(WCOR/WCOR0)^2*EFF;
end

% 计算出口参数
OUTPUT.T    = T1;
OUTPUT.P    = P*TPR;
OUTPUT.TPR  = TPR;
OUTPUT.WCOR = WCOR;
OUTPUT.thermal_geometry = thermal_geometry;
OUTPUT.flow_state = flow_state;
OUTPUT.material_props = material_props;
OUTPUT.node_data = node_data;

OUTPUT.pmsm_params.thermal.thermal_resistance = R;
OUTPUT.pmsm_params.thermal.dT_air             = dT_air*EFF;
OUTPUT.pmsm_params.thermal.dT_pmsm_partial    = dT_pmsm_partial;
OUTPUT.pmsm_params.thermal.temp_balance       = T_thermal_balance-273;
OUTPUT.pmsm_params.thermal.dH_pmsm_partial    = [Q_Fe;Q_Cu].*dT_pmsm_partial/1000;
end
