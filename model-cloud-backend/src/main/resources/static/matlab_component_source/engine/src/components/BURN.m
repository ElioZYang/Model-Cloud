function [OUTPUT]=BURN(INPUT)
%根据燃烧室进出口温度、燃烧效率与燃油热值利用等温焓差计算油气比
%Fuel Air Ratio of Combustor 
%输入参数
% T1    进口温度
% T2    出口温度
% Eb    燃烧效率
% Hu    燃油热值
%输出参数
% FAR   油气比
OUTPUT=INPUT;
T1=INPUT.T;
WF=INPUT.WF;
WA=INPUT.WA;
TIT=max(INPUT.TO,INPUT.T);
Hu=INPUT.HU;
Eb=INPUT.EB;
if (INPUT.TO)>=0 % 涡轮前温度给定
if TIT<=INPUT.T
OUTPUT.FAR=0;
else
OUTPUT.FAR=(SE(TIT,0)-SE(T1,0))/(Hu*Eb-Hso(TIT)+SE(T1,0));
end
elseif WF>0
OUTPUT.FAR=WF/WA;
TIT0=OUTPUT.FAR*Eb*Hu/CPSH(T1,0)+T1;
TIT=fzero(@(x) (SE(x,0)-SE(T1,0))/(Hu*Eb-Hso(x)+SE(T1,0))/OUTPUT.FAR-1,TIT0);
else
OUTPUT.FAR=0;
TIT=T1;
end
OUTPUT.P=INPUT.P*INPUT.TPR;
OUTPUT.T=TIT;
OUTPUT.KB=(OUTPUT.T-INPUT.T)/(OUTPUT.FAR-INPUT.FAR);
OUTPUT.WF=WA*OUTPUT.FAR;
OUTPUT.W=WA+WF;
end
function [H_fuel]=Hso(TIT)
H_fuel=(-43.8175 + 1.36068*TIT + 0.00119*TIT^2 ...
      -2.05199e-7*TIT^3 + 1.11942e-11*TIT^4)*1000;
end