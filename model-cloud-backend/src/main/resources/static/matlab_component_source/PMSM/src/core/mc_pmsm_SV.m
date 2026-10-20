function [ V ] = mc_pmsm_SV(Ts,FAR,D)
%计算声速
%Sound Velocity 
%输入变量
% Ts     温度
%输出参数
% V     声速
V=sqrt(mc_pmsm_AE(Ts,FAR,D)*mc_pmsm_GC(FAR,D)*Ts);
end

