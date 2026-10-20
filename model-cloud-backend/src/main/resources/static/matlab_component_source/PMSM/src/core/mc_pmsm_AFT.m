function [ TL ] = mc_pmsm_AFT( mc_pmsm_VC,K )
%计算温度气动函数
%Aerodynamic Function of Temperature 
%输入参数
% mc_pmsm_VC    速度系数
% K     绝热指数
%输出参数
% TL    温度气动函数
A=K+1;
B=K-1;
TL=1 - B/A*mc_pmsm_VC^2;
end

