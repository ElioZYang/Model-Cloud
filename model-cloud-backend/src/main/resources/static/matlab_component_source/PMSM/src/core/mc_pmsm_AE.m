function [ K ] = mc_pmsm_AE(T,FAR,D)
%根据温度,油气比与相对湿度计算气体绝热指数
%Adiabatic Exponent
%输入参数
% T     温度
% FAR  油气比
%输出参数
% K     绝热指数
K=mc_pmsm_CPSH(T,FAR)/(mc_pmsm_CPSH(T,FAR)-mc_pmsm_GC(FAR,D));
end

