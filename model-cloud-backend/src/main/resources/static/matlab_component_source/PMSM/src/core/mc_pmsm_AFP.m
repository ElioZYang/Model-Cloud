function [ PL ] = mc_pmsm_AFP( mc_pmsm_VC,K )
%计算压力气动函数
%Aerodynamic Function of Pressure 
%输入参数
% mc_pmsm_VC    速度系数
% K     绝热指数
%输出参数
% PL    压力气动函数
A=K+1;
B=K-1;
PL=(1 - B/A*mc_pmsm_VC^2)^(K/B);
end

