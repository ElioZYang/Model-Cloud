function [Ps,Ts,P0,T0]=STAGNATION_CAL(H,V,M,DT,QP)
[ Ts,Ps,~,sv,~ ] = ASP( H,DT,QP);
K0=AE(Ts,0,0);
if V>=0
% calculate mach via velocity
M=V/sv;
end
T0=Ts*(1+(K0-1)/2*M^2);
P0=Ps*(1+(K0-1)/2*M^2)^(K0/(K0-1));
end