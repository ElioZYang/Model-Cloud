function [ PL ] = AFP( VC,K )
%计算压力气动函数
%Aerodynamic Function of Pressure 
%输入参数
% VC    速度系数
% K     绝热指数
%输出参数
% PL    压力气动函数
A=K+1;
B=K-1;
PL=(1 - B/A*VC^2)^(K/B);
end

