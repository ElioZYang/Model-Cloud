function [thermalNetwork,coolingFlow,motorModel]=mc_pmsm_c_network_liquid(motorModel,thermalGeometry,flowState,materialProperties,thermalBoundary)
pmsm_params=motorModel;
A_slot=thermalGeometry.A_slot;
A_stator=thermalGeometry.A_stator;
Area=thermalGeometry.Area;
C_cgv=thermalGeometry.C_cgv;
H_open=thermalGeometry.H_open;
H_slot=thermalGeometry.H_slot;
L=thermalGeometry.L;
N_slot=thermalGeometry.N_slot;
Rho=thermalGeometry.Rho;
Ri=thermalGeometry.Ri;
Ro=thermalGeometry.Ro;
Rro=thermalGeometry.Rro;
g=thermalGeometry.g;
omega=thermalGeometry.omega;
theta=thermalGeometry.theta;
theta0=thermalGeometry.theta0;
theta1=thermalGeometry.theta1;
theta2=thermalGeometry.theta2;
v_rotor=thermalGeometry.v_rotor;
W=flowState.W;
K=flowState.K;
Ts_amb=flowState.Ts_amb;
rhos=flowState.rhos;
t_iso=materialProperties.t_iso;
k_iso=materialProperties.k_iso;
k_stator=materialProperties.k_stator;
k_housing=materialProperties.k_housing;
k_slot=materialProperties.k_slot;
T=thermalBoundary.T;
FAR=thermalBoundary.FAR;
T_Fe=thermalBoundary.T_Fe;
T_Cu=thermalBoundary.T_Cu;
%% 计算无量纲参数
mu=mc_pmsm_MU(Ts_amb);
k_air = (0.0015215 + 0.097459*Ts_amb - 3.3322e-5*Ts_amb.^2) * 1e-3;
Re_cgv=W*C_cgv/Area/mu;
Re_shell=W*L/Area/mu;
CP=mc_pmsm_CPSH(T,FAR);
Pr=CP*mu/k_air;
%% LPTN法求解温升
% 轴向热阻
Rx_winding=L/2/k_slot/A_slot;
Rx_fe=L/2/k_stator/A_stator;
% 端部热阻
h_end=mc_pmsm_conv_stator_end(v_rotor);
Rx_winding_end=1/h_end/A_slot;
Rx_fe_end=1/h_end/A_stator;
% 绕组热阻
Rt_winding=mc_pmsm_Rt_cyn(Ri+H_open,Ri+H_slot,.5*theta0,L,k_slot ...
    )+t_iso/k_iso/(H_slot-H_open)/L;% 周向
Rr_winding1=mc_pmsm_Rr_cyn(Ri+H_open,Ri+.5*(H_slot+H_open),theta0,L,k_slot ...
    )+mc_pmsm_Rr_cyn(Ri+H_open,Ri+H_open+t_iso,theta0,L,k_iso);% 内圈
Rr_winding2=mc_pmsm_Rr_cyn(Ri+.5*(H_slot+H_open),Ri+H_slot,theta0,L,k_slot ...
    )+mc_pmsm_Rr_cyn(Ri+H_slot-t_iso,Ri+H_slot,theta0,L,k_iso);% 外圈
% 气隙热阻
Nu_gap=mc_pmsm_Nu_airgap(rhos,mu,omega,Ri-.5*g,g);
h_airgap=Nu_gap*k_air/g;
% h_airgap=mc_pmsm_conv_airgap(g,Rro,omega,mu,k_air);
R_airgap=1/h_airgap/L/theta/(Ri-.5*g);
% 齿部热阻
Rr_teeth=mc_pmsm_Rr_cyn(Ri,Ri+H_open,theta2,L,k_stator);% 内圈
% 轭部热阻
Rt_yoke=mc_pmsm_Rt_cyn(Ri+H_open,Ri+H_slot,theta1,L,k_stator);
Rr_yoke1=mc_pmsm_Rr_cyn(Ri+H_open,Ri+.5*(H_slot+H_open),theta1,L,k_stator);% 内圈
Rr_yoke2=mc_pmsm_Rr_cyn(Ri+.5*(H_slot+H_open),Ri+H_slot,theta1,L,k_stator);% 外圈
Rr_yoke3=mc_pmsm_Rr_cyn(Ri+H_slot,Ro,theta,L,k_stator);
% 机壳热阻
Rr_housing=mc_pmsm_Rr_cyn(Ro,Rho,theta,L,k_housing);
% Rr_shell=mc_pmsm_Rr_cyn(Rho,Rho+0.01,theta,L,k_housing);
% 水冷套对流换热热阻
fluid_props.rho = 999.7;      % 密度 kg/m³
    fluid_props.mu = 1.306e-3;    % 动力粘度 Pa·s
    fluid_props.cp = 4195;        % 比热容 J/kg·K
    fluid_props.k = 0.582;        % 导热系数 W/m·K
    fluid_props.Pr = 9.41;        % 普朗特数 (计算值: mu*cp/k)
channel_width=2*pi*Rho/N_slot;
channel_height=.5*channel_width;
v_liquid=1.0;
h_liquid=mc_pmsm_calculate_rectangular_duct_h(v_liquid,channel_width,channel_height,fluid_props);
A_liquid=channel_width*L;
NTU=h_liquid*A_liquid/fluid_props.rho/fluid_props.cp/v_liquid/channel_width/channel_height;
eff_hex=1-exp(-NTU);
R_liquid_housing=NTU/h_liquid/A_liquid/eff_hex;
% 搭建热阻网络矩阵
mass_Cu=pmsm_params.mass.copper;
mass_Fe=pmsm_params.mass.stator_tooth+pmsm_params.mass.stator_yoke;
Q_Cu=mc_pmsm_copper_heat_capacity(T_Cu)*mass_Cu;
Q_Fe=mc_pmsm_steel_heat_capacity(T_Fe)*mass_Fe;
PW_Cu=pmsm_params.losses.copper;
PW_Fe=pmsm_params.losses.total-PW_Cu;
PW_in=[0;PW_Fe/2/N_slot;PW_Cu/2/N_slot];
N_node=4;
R=tril(inf(N_node,N_node));
% R(6,4)=Rr_winding1;
% R(6,3)=Rr_yoke1;
% R(6,1)=Rr_teeth+R_airgap;
R(4,3)=Rr_winding2;
R(4,2)=Rr_yoke2;
% R(5,2)=Rr_yoke3+Rr_housing+R_liquid_housing+R_amb_cgv;
R(4,1)=Rr_yoke3+Rr_housing+R_liquid_housing*2;
R(3,2)=Rt_yoke+Rt_winding;
% R(4,1)=Rx_winding+Rx_winding_end;
% R(3,1)=Rx_fe+Rx_fe_end;
R=R+R';
LM1=1;
LM2=[2;3];
C=[1E3*W*CP/N_slot/2;Q_Fe/N_slot/2;Q_Cu/N_slot/2];
Ts_liquid=10+273;
T_in=[Ts_liquid;T_Fe;T_Cu];
% 计算绕组温升率

thermalNetwork=struct('R',R,'C',C,'PW_in',PW_in,'T_in',T_in,'LM1',LM1,'LM2',LM2,'Q_Fe',Q_Fe,'Q_Cu',Q_Cu);
coolingFlow=struct('Re_cgv',Re_cgv);
motorModel.input.cooling=3;
end
