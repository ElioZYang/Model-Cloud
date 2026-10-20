function [ V ] = SV(Ts,FAR,D)
%计算声速
%Sound Velocity 
%输入变量
% Ts     温度
%输出参数
% V     声速
V=sqrt(AE(Ts,FAR,D)*GC(FAR,D)*Ts);
end

