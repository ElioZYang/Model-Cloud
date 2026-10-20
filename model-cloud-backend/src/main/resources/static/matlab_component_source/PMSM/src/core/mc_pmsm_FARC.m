function [ FAR ] = mc_pmsm_FARC( T1,T2,Eb,Hu)
%根据燃烧室进出口温度、燃烧效率与燃油热值利用等温焓差计算油气比
%Fuel Air Ratio of Combustor 
%输入参数
% T1    进口温度
% T2    出口温度
% Eb    燃烧效率
% Hu    燃油热值
%输出参数
% FAR   油气比
Hso=(-43.8175 + 1.36068*T2 + 0.00119*T2.^2 ...
      -2.05199e-7*T2.^3 + 1.11942e-11*T2.^4)*1000;
FAR=(mc_pmsm_SE(T2,0)-mc_pmsm_SE(T1,0))/(Hu*Eb-Hso+mc_pmsm_SE(T1,0));
end

