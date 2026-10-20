function[OUTPUT]=mc_pmsm_MIXER(INPUT,INPUT1)
% 混合器（加力燃烧室/喷管前）
T=INPUT.T;
P=INPUT.P;
D=INPUT.D;
WA=INPUT.WA;
FAR=INPUT.FAR;
W=WA*(1+FAR);
H=mc_pmsm_SE(T,FAR);
K=mc_pmsm_AE(T,FAR,D);
WCOR=W*T^0.5/P;
% 外涵道
T1=INPUT1.T;
P1=INPUT1.P;
D1=INPUT1.D;
WA1=INPUT1.WA;
FAR1=INPUT1.FAR;
W1=WA1*(1+FAR1);
H1=mc_pmsm_SE(T1,FAR1);
K1=mc_pmsm_AE(T1,FAR1,D1);
WCOR1=W1*T1^0.5/P1;
% 混合器出口已知条件
WA2=WA+WA1;
W2=W+W1;
FAR2=W2/WA2-1;
H2=(W*H+W1*H1)/W2;
D2=(W*D+W1*D1)/W2;
T2=mc_pmsm_TT(H2,FAR2);
K2=mc_pmsm_AE(T2,FAR2,D2);
OUTPUT.WA=WA2;
OUTPUT.FAR=FAR2;
OUTPUT.T=T2;
OUTPUT.D=D2;
OUTPUT.W=W2;
switch INPUT.mode
    case "design"
Ps_max=min(P,P1);
Ps_ini=min(P,P1)/mc_pmsm_TOTAL_PRESSURE(INPUT.M_mixed,K);
% Ps_array=linspace(0,Ps_ini,100);
% for k=1:100
%     DW1(k)=MIXER_BALANCE_DESIGN(Ps_array(k),INPUT.M_mixed);
%     disp(DW1(k))
% end
Ps_sol=fzero(@(Ps) MIXER_BALANCE_DESIGN(Ps,INPUT.M_mixed),Ps_ini);
[DW,AN,AN1,M,M1,P2]=MIXER_BALANCE_DESIGN(Ps_sol,INPUT.M_mixed);
OUTPUT.AN_mixer=[AN,AN1];
OUTPUT.M_unmixed=[M,M1];
OUTPUT.P=P2;
    case "offdesign"
AN_mixer=INPUT.AN_mixer;
AN=AN_mixer(1);
AN1=AN_mixer(2);
AN2=AN+AN1;
M_unmixed=INPUT.M_unmixed;
Q=WCOR/AN;
mc_pmsm_VC=fzero(@(X) mc_pmsm_FC(X,K,FAR,D)/Q-1,mc_pmsm_LAMBDA(M_unmixed(1),K,1));
M=mc_pmsm_LAMBDA(mc_pmsm_VC,K,2);
Ps=P/mc_pmsm_TOTAL_PRESSURE(M,K);
V=M*mc_pmsm_SV(T/mc_pmsm_TOTAL_TEMP(M,K),FAR,D);
Q1=WCOR1/AN1;
VC1=fzero(@(X) mc_pmsm_FC(X,K1,FAR1,D1)/Q1-1,mc_pmsm_LAMBDA(M_unmixed(2),K1,1));
M1=mc_pmsm_LAMBDA(VC1,K1,2);
Ps1=P1/mc_pmsm_TOTAL_PRESSURE(M1,K1);
V1=M1*mc_pmsm_SV(T1/mc_pmsm_TOTAL_TEMP(M1,K1),FAR1,D1);
M2_sol=fzero(@(M2) MIXER_BALANCE_OFFDESIGN(M2),INPUT.M_mixed);
[DW,DPs,P2]=MIXER_BALANCE_OFFDESIGN(M2_sol);
OUTPUT.DPs=DPs;
OUTPUT.P=P2;
end
function[DW,AN,AN1,M,M1,P2]=MIXER_BALANCE_DESIGN(Ps,M2)
V2=M2*mc_pmsm_SV(T2/mc_pmsm_TOTAL_TEMP(M2,K2),FAR2,D2);
VC2=mc_pmsm_LAMBDA(M2,K2,1);
% Initial Guestimate
M=(((P/Ps)^((K-1)/K)-1)*2/(K-1))^0.5;
V=M*mc_pmsm_SV(T/mc_pmsm_TOTAL_TEMP(M,K),FAR,D);
mc_pmsm_VC=mc_pmsm_LAMBDA(M,K,1);
% Mixer Inlet Static Pressure Balance
M1=(((P1/Ps)^((K1-1)/K1)-1)*2/(K1-1))^0.5;
V1=M1*mc_pmsm_SV(T1/mc_pmsm_TOTAL_TEMP(M1,K1),FAR1,D1);
VC1=mc_pmsm_LAMBDA(M1,K1,1);
% Mixer Momentum Balance
AN=WCOR/mc_pmsm_FC(mc_pmsm_VC,K,FAR,D);
AN1=WCOR1/mc_pmsm_FC(VC1,K1,FAR1,D1);
AN2=AN+AN1;
Ps2=Ps+(W*V+W1*V1-W2*V2)/AN2;
P2=Ps2*mc_pmsm_TOTAL_PRESSURE(M2,K2);
% Mixer Flow Balance
W2_cal=AN2*mc_pmsm_FC(VC2,K2,FAR2,D2)*P2/(T2)^0.5;
DW=W2_cal/W2-1;
DW=real(DW);
DW=min(DW,999);
DW=max(DW,-999);
disp(DW)
end
function[DW,DPs,P2]=MIXER_BALANCE_OFFDESIGN(M2)
% Initial Guestimate
VC2=mc_pmsm_LAMBDA(M2,K2,1);
Q2=mc_pmsm_FC(VC2,K2,FAR2,D2);
V2=M2*mc_pmsm_SV(T2/mc_pmsm_TOTAL_TEMP(M2,K2),FAR2,D2);
Ps2=(Ps*AN+Ps1*AN1)/AN2+(W*V+W1*V1-W2*V2)/AN2;
P2=Ps2*mc_pmsm_TOTAL_PRESSURE(M2,K2);
W2_cal=AN2*Q2*P2/(T2)^0.5;
DW=W2_cal/W2-1;
DPs=(Ps-Ps1)/101325;
end
end
% function[K]=GAMMA(M,T,FAR,D)
% % 已知马赫数、总温、油气比、湿度，求比热比
% fun=@(Ts) T/(1+(mc_pmsm_AE(Ts,FAR,D)-1)/2*M^2)-Ts;
% Ts=fzero(fun,T/(1+0.2*M^2));
% K=mc_pmsm_AE(Ts,FAR,D);
% end
% function[dV]=D_VELOCITY(M,V,T,FAR,D)
% % 已知马赫数、预估速度、总温、油气比、湿度，求实际计算得到速度与预估速度的差值
% K=GAMMA(M,T,FAR,D);
% R=mc_pmsm_GC(FAR,D);
% dV=V-M*sqrt(K*R*T/(1+(K-1)/2*M^2));
% end