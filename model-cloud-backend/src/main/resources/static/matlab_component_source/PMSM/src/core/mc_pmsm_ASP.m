function [ Ts,Ps,rhos,sv,mu ] = mc_pmsm_ASP( H,DT,QP)
%计算大气静温与静压
%Atmosphere Static Paremeters
%输入参数
% H     飞行高度
% DT   气流温度与标准大气温度之差
% QP   气流压力与标准大气压力之比
%输出参数
% Ts   气流静温
% Ps   气流静压
% rhos 密度
% sv 声速
% mu 黏度系数
H=max(H,0);
if H<11000
    Ts=288.16-0.0065*H;
    Ps=101325.00*(1-H/44308).^5.2553;
elseif H<24994
    Ts=216.65;
    Ps=2306.1*9.80665*exp((11000 - H)/6318.);
else
    Ts = 216.65+0.0029892*(H-24994.);
    Ps = 2523.7*(216.65/Ts).^11.8;
end
Ts=Ts+DT;
Ps=Ps*QP/100;
R=mc_pmsm_GC(0,0);
rhos=Ps./R./Ts;
sv=mc_pmsm_SV(Ts,0,0);
mu=mc_pmsm_MU(Ts);
end




