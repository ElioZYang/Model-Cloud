function [ Q ] = FC( VC,K,FAR,D )
%根据气体速度系数、绝热指数、油气比和绝对湿度计算气体流量函数K*q(VC)
%Flow Function
%输入参数
% VC    速度系数
% K     绝热指数
% FAR   油气比
%输出参数
% Q     流量函数
A=K+1;
B=K-1;
Q=sqrt(K/GC(FAR,D)*(2/A)^(A/B))*VC*(A/2)^(1/B)*(1-B/A*VC^2)^(1/B);
end