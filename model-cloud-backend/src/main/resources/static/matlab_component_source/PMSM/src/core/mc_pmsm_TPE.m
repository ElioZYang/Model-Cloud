function [ T2,P2] = mc_pmsm_TPE( DHs,Es,T1,P1,FAR )
%根据焓降，效率，进口温度与压力考虑变比热影响计算膨胀过程
%Total Parameters of Expand 
%输入参数
% DHs   焓降
% mc_pmsm_E     等熵效率
% T1    进口温度
% p2    进口压力
% FAR   油气比
%输出参数
% T2    出口温度
% P2    出口压力
h_in=mc_pmsm_SE(T1,FAR);
s_in=mc_pmsm_E(T1,P1,FAR);
h_out_s=h_in-DHs/Es;
T2=mc_pmsm_TT(h_out_s,FAR);
P2=P1/2;
D_s=100;
while(abs(D_s)>=0.00005*s_in)
    s_out=mc_pmsm_E(T2,P2,FAR);
    D_s=s_out-s_in;
    P2=P1*exp(D_s/mc_pmsm_GC(FAR) + log(P2/P1));
end
h_out=h_in-DHs;
T2=mc_pmsm_TT(h_out,FAR);
end

