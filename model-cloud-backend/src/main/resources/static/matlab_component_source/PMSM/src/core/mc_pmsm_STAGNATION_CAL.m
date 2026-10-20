function [Ps,Ts,P0,T0]=mc_pmsm_STAGNATION_CAL(H,V,M,DT,QP)
[ Ts,Ps,~,sv,~ ] = mc_pmsm_ASP( H,DT,QP);
K0=mc_pmsm_AE(Ts,0,0);
if V>=0
% calculate mach via velocity
M=V/sv;
end
T0=Ts*(1+(K0-1)/2*M^2);
P0=Ps*(1+(K0-1)/2*M^2)^(K0/(K0-1));
end