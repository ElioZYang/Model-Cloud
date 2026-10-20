function [ I ] = mc_pmsm_IF( W,K,mc_pmsm_VC,T,FAR )
%根据气体流量、速度系数、绝热指数、温度、油气比和绝对湿度计算气体冲量函数
%Impulse Function
%输入参数
% W     流量
% mc_pmsm_VC    速度系数
% K     绝热指数
% T     温度
% FAR   油气比
%输出参数
% I     冲量函数
zlxx=mc_pmsm_VC+1/mc_pmsm_VC;
I=W*sqrt((K + 1)/2/K*mc_pmsm_GC(FAR)*T)*zlxx;
end

