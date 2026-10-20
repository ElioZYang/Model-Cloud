function [ OUTPUT ] = mc_pmsm_AFTERBURN(INPUT)
%根据加力燃烧室进出口温度、燃烧效率与燃油热值利用等温焓差计算加力燃烧室燃油对应的油气比
%Fuel Air Ratio of After Burner
%输入参数
% T_in  进口温度
% T_out 出口温度
% far_in进口油气比
% eb    燃烧效率
% hf    燃油热值
%输出参数
% far   油气比
OUTPUT=INPUT;
T_in=OUTPUT.T;
T_out=OUTPUT.TO;
if T_out==0% 加力关闭
OUTPUT.P=INPUT.TPR*INPUT.P;
OUTPUT.KB=0;
else
eb=OUTPUT.EB;
hf=OUTPUT.HU;
far_in=OUTPUT.FAR;
h_di=(-17.2199+0.3553492*T_in+2.402099e-4*T_in^2 ...
       -2.43542e-8*T_in^3 - 2.12462e-12*T_in^4)*427;
h_do=(-17.2199+0.3553492*T_out+2.402099e-4*T_out^2 ...
       -2.43542e-8*T_out^3 -2.12462e-12*T_out^4)*427.;
OUTPUT.FAR=(far_in*(h_do - h_di) + (mc_pmsm_SE(T_out,0) - mc_pmsm_SE(T_in,0))...
    /9.80665)/(hf/10*eb - h_do + mc_pmsm_SE(T_in,0)/9.80665);
OUTPUT.T=T_out;
OUTPUT.P=INPUT.P*INPUT.TPR;
OUTPUT.KB=(OUTPUT.T-INPUT.T)/(OUTPUT.FAR-INPUT.FAR);
end
end
