function [ Q ] = mc_pmsm_FC( mc_pmsm_VC,K,FAR,D )
%根据气体速度系数、绝热指数、油气比和绝对湿度计算气体流量函数K*q(mc_pmsm_VC)
%Flow Function
%输入参数
% mc_pmsm_VC    速度系数
% K     绝热指数
% FAR   油气比
%输出参数
% Q     流量函数
A=K+1;
B=K-1;
Q=sqrt(K/mc_pmsm_GC(FAR,D)*(2/A)^(A/B))*mc_pmsm_VC*(A/2)^(1/B)*(1-B/A*mc_pmsm_VC^2)^(1/B);
end