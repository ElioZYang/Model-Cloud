function thermal_network = build_thermal_network_air( ...
    thermal_geometry,flow_state,material_props,node_data)
%BUILD_THERMAL_NETWORK_AIR 构建并求解空气冷却热网络。
% 四个输入结构体分别描述几何、流动、材料和热节点数据。

T       = flow_state.T;
FAR     = flow_state.FAR;
W       = flow_state.W;
Ts_amb  = flow_state.Ts_amb;
rhos    = flow_state.rhos;

k_slot    = material_props.k_slot;
k_stator  = material_props.k_stator;
k_housing = material_props.k_housing;
k_iso     = material_props.k_iso;
t_iso     = material_props.t_iso;

T_Cu      = node_data.copper_temperature_K;
T_Fe      = node_data.iron_temperature_K;

g         = thermal_geometry.g;
Ri        = thermal_geometry.Ri;
Ro        = thermal_geometry.Ro;
Rho       = thermal_geometry.Rho;
L         = thermal_geometry.L;
N_slot    = thermal_geometry.N_slot;
slot_fill = thermal_geometry.slot_fill;
H_slot    = thermal_geometry.H_slot;
H_open    = thermal_geometry.H_open;
A_slot    = thermal_geometry.A_slot;
A_stator  = thermal_geometry.A_stator;
omega     = thermal_geometry.omega;
v_rotor   = thermal_geometry.v_rotor;
theta     = thermal_geometry.theta;
theta0    = thermal_geometry.theta0;
theta1    = thermal_geometry.theta1;
theta2    = thermal_geometry.theta2;
H_cgv     = thermal_geometry.H_cgv;
C_cgv     = thermal_geometry.C_cgv;
Area      = thermal_geometry.Area;

%% 计算无量纲参数
mu=MU(Ts_amb);
k_air = (0.0015215 + 0.097459*Ts_amb - 3.3322e-5*Ts_amb.^2) * 1e-3;
Re_cgv=W*C_cgv/Area/mu;
Re_shell=W*L/Area/mu;
CP=CPSH(T,FAR);
Pr=CP*mu/k_air;
%% LPTN法求解温升

% 轴向热阻
Rx_winding=L/2/k_slot/A_slot;
Rx_fe=L/2/k_stator/A_stator;
% 端部热阻
h_end=conv_stator_end(v_rotor);
Rx_winding_end=1/h_end/A_slot;
Rx_fe_end=1/h_end/A_stator;
% 绕组热阻
Rt_winding=Rt_cyn(Ri+H_open,Ri+H_slot,.5*theta0,L,k_slot ...
    )+t_iso/k_iso/(H_slot-H_open)/L;% 周向
Rr_winding1=Rr_cyn(Ri+H_open,Ri+.5*(H_slot+H_open),theta0,L,k_slot ...
    )+Rr_cyn(Ri+H_open,Ri+H_open+t_iso,theta0,L,k_iso);% 内圈
Rr_winding2=Rr_cyn(Ri+.5*(H_slot+H_open),Ri+H_slot,theta0,L,k_slot ...
    )+Rr_cyn(Ri+H_slot-t_iso,Ri+H_slot,theta0,L,k_iso);% 外圈
% 气隙热阻
Nu_gap=Nu_airgap(rhos,mu,omega,Ri-.5*g,g);
h_airgap=Nu_gap*k_air/g;
% h_airgap=conv_airgap(g,Rro,omega,mu,k_air);
R_airgap=1/h_airgap/L/theta/(Ri-.5*g);
% 齿部热阻
Rr_teeth=Rr_cyn(Ri,Ri+H_open,theta2,L,k_stator);% 内圈
% 轭部热阻
Rt_yoke=Rt_cyn(Ri+H_open,Ri+H_slot,theta1,L,k_stator);
Rr_yoke1=Rr_cyn(Ri+H_open,Ri+.5*(H_slot+H_open),theta1,L,k_stator);% 内圈
Rr_yoke2=Rr_cyn(Ri+.5*(H_slot+H_open),Ri+H_slot,theta1,L,k_stator);% 外圈
Rr_yoke3=Rr_cyn(Ri+H_slot,Ro,theta,L,k_stator);
% 机壳热阻
Rr_housing1=Rr_cyn(Ro,Rho/2+Ro/2,theta,L,k_housing);
Rx_housing=Rx_cyn(Ro,Rho,theta,L*0.5,k_housing);
Rr_housing2=Rr_cyn(Rho/2+Ro/2,Rho,theta,L,k_housing);
Rr_housing=Rr_housing2+Rx_housing+Rr_housing1;
% 机壳对流换热热阻
Nu_housing=Nu_cgv(Re_shell,Pr);
h_housing=Nu_housing*k_air/L;
R_amb_housing=1/(h_housing*L*theta*Rho);
% 热管导叶传热热阻
% 曲管
% HPWidth=H_slot-H_open;
% HPthick=theta*(Ri+.5*(H_slot+H_open))*2*(1-slot_fill);
% L_e=L;
% L_iso=0.2*L+Rho-(Ri+.5*(H_slot+H_open));
% L_c=H_cgv;
% 直管
HPWidth=.5*C_cgv;
HPthick=theta*(Ri+.5*(H_slot+H_open))*2*(1-slot_fill);
L_e=H_slot;
L_iso=Rho-(Ri+H_slot);
L_c=H_cgv;
R_hp=R_heatpipe(L_e,L_iso,L_c,HPWidth,HPthick);
% k_hp=1e4;
% R_hp=(H_slot/2+Rho-Ri-H_slot+H_cgv/2)/(k_hp*C_cgv*HPthick);
% 热管导叶对流换热热阻
Nu_vane=Nu_cgv(Re_cgv,Pr);
h_amb_cgv=Nu_vane*k_air/C_cgv;
% h_force_conv=500;
R_amb_cgv=1/h_amb_cgv/H_cgv/C_cgv;
% 搭建热阻网络矩阵
mass_Cu=node_data.copper_mass_kg;
mass_Fe=node_data.stator_tooth_mass_kg+node_data.stator_yoke_mass_kg;
Q_Cu=copper_heat_capacity(T_Cu)*mass_Cu;
Q_Fe=steel_heat_capacity(T_Fe)*mass_Fe;
PW_Cu=node_data.copper_loss_W;
PW_Fe=node_data.total_loss_W-PW_Cu;
PW_in=[0;PW_Fe/2/N_slot;PW_Cu/2/N_slot];
N_node=6;
R=tril(inf(N_node,N_node));
R(6,4)=Rr_winding1;
R(6,3)=Rr_yoke1;
R(6,1)=Rr_teeth+R_airgap;
R(5,4)=Rr_winding2;
R(5,3)=Rr_yoke2;
R(5,2)=Rr_yoke3+Rr_housing+R_amb_housing*R_amb_cgv/(R_amb_housing+R_amb_cgv);
R(4,3)=Rt_yoke+Rt_winding;
R(4,1)=Rx_winding+Rx_winding_end;
R(3,1)=Rx_fe_end+Rx_fe;
R=R+R';
LM1=[1;2];
LM2=[3;4];
C=[W*CP/N_slot/2;Q_Fe/N_slot/2;Q_Cu/N_slot/2];
T_in=[Ts_amb;T_Fe;T_Cu];
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
