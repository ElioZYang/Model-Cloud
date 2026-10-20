function thermal_network = build_thermal_network_liquid( ...
    thermal_geometry,flow_state,material_props,node_data)
%BUILD_THERMAL_NETWORK_LIQUID 构建并求解液冷热网络。
% 四个输入结构体分别描述几何、流动、材料和热节点数据。

T       = flow_state.T;
FAR     = flow_state.FAR;
W       = flow_state.W;
Ts_amb  = flow_state.Ts_amb;

k_slot    = material_props.k_slot;
k_stator  = material_props.k_stator;
k_housing = material_props.k_housing;
k_iso     = material_props.k_iso;
t_iso     = material_props.t_iso;

T_Cu      = node_data.copper_temperature_K;
T_Fe      = node_data.iron_temperature_K;

Ri        = thermal_geometry.Ri;
Ro        = thermal_geometry.Ro;
Rho       = thermal_geometry.Rho;
L         = thermal_geometry.L;
N_slot    = thermal_geometry.N_slot;
H_slot    = thermal_geometry.H_slot;
H_open    = thermal_geometry.H_open;
theta     = thermal_geometry.theta;
theta0    = thermal_geometry.theta0;
theta1    = thermal_geometry.theta1;
C_cgv     = thermal_geometry.C_cgv;
Area      = thermal_geometry.Area;

%% 计算无量纲参数
mu=MU(Ts_amb);
Re_cgv=W*C_cgv/Area/mu;
CP=CPSH(T,FAR);

%% LPTN法求解温升


% 绕组热阻
Rt_winding=Rt_cyn(Ri+H_open,Ri+H_slot,.5*theta0,L,k_slot ...
    )+t_iso/k_iso/(H_slot-H_open)/L;% 周向

Rr_winding2=Rr_cyn(Ri+.5*(H_slot+H_open),Ri+H_slot,theta0,L,k_slot ...
    )+Rr_cyn(Ri+H_slot-t_iso,Ri+H_slot,theta0,L,k_iso);% 外圈

% h_airgap=conv_airgap(g,Rro,omega,mu,k_air);


% 轭部热阻
Rt_yoke=Rt_cyn(Ri+H_open,Ri+H_slot,theta1,L,k_stator);
Rr_yoke2=Rr_cyn(Ri+.5*(H_slot+H_open),Ri+H_slot,theta1,L,k_stator);% 外圈
Rr_yoke3=Rr_cyn(Ri+H_slot,Ro,theta,L,k_stator);
% 机壳热阻
Rr_housing=Rr_cyn(Ro,Rho,theta,L,k_housing);
% Rr_shell=Rr_cyn(Rho,Rho+0.01,theta,L,k_housing);
% 水冷套对流换热热阻
fluid_props.rho = 999.7;          % 密度 kg/m³
    fluid_props.mu = 1.306e-3;    % 动力粘度 Pa·s
    fluid_props.cp = 4195;        % 比热容 J/kg·K
    fluid_props.k = 0.582;        % 导热系数 W/m·K
    fluid_props.Pr = 9.41;        % 普朗特数 (计算值: mu*cp/k)

channel_width=2*pi*Rho/N_slot;
channel_height=.5*channel_width;
v_liquid = 1.0;
h_liquid = calculate_rectangular_duct_h(v_liquid,channel_width,channel_height,fluid_props);
A_liquid = channel_width*L;
NTU = h_liquid*A_liquid/fluid_props.rho/fluid_props.cp/v_liquid/channel_width/channel_height;
eff_hex = 1-exp(-NTU);
R_liquid_housing = NTU/h_liquid/A_liquid/eff_hex;
% 搭建热阻网络矩阵
mass_Cu=node_data.copper_mass_kg;
mass_Fe=node_data.stator_tooth_mass_kg+node_data.stator_yoke_mass_kg;
Q_Cu=copper_heat_capacity(T_Cu)*mass_Cu;
Q_Fe=steel_heat_capacity(T_Fe)*mass_Fe;
PW_Cu=node_data.copper_loss_W;
PW_Fe=node_data.total_loss_W-PW_Cu;
PW_in=[0;PW_Fe/2/N_slot;PW_Cu/2/N_slot];
N_node=4;
R=tril(inf(N_node,N_node));

% R(4,1)=Rx_winding+Rx_winding_end;
% R(3,1)=Rx_fe+Rx_fe_end;
R(4,3)=Rr_winding2;
R(4,2)=Rr_yoke2;
R(4,1)=Rr_yoke3+Rr_housing+R_liquid_housing*2;
R(3,2)=Rt_yoke+Rt_winding;

R=R+R';
LM1=1;
LM2=[2;3];
C=[1E3*W*CP/N_slot/2;Q_Fe/N_slot/2;Q_Cu/N_slot/2];
Ts_liquid=10+273;
T_in=[Ts_liquid;T_Fe;T_Cu];
% 计算绕组温升率
[dTdt,T_thermal_balance] = thermal_balance_solver(R, C, PW_in, T_in,LM1,LM2);
dT_air=dTdt(1);
dT_pmsm_partial=dTdt(2:end);

thermal_network = struct( ...
    'R',R, ...
    'C',C, ...
    'PW_in',PW_in, ...
    'T_in',T_in, ...
    'LM1',LM1, ...
    'LM2',LM2, ...
    'dTdt',dTdt, ...
    'T_thermal_balance',T_thermal_balance, ...
    'dT_air',dT_air, ...
    'dT_pmsm_partial',dT_pmsm_partial, ...
    'Q_Fe',Q_Fe, ...
    'Q_Cu',Q_Cu, ...
    'Re_cgv',Re_cgv);
end
