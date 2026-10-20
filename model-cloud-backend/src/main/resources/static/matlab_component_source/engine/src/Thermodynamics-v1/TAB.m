function [ T ] = TAB( T_in,farab,far_in,eb,hf)
%根据气体速度系数、绝热指数、油气比和绝对湿度计算气体流量函数K*q(VC)
%Temperature of After Burner
%输入参数
% T_in  进口温度
% far_in进口油气比
% eb    燃烧效率
% hf    燃油热值
% farab 加力燃油油气比
%输出参数
% T    加力温度
F=@(X) FARAB( T_in,X,far_in,eb,hf)-farab;
X=[0,2500];
T=fzero(F,X);
end