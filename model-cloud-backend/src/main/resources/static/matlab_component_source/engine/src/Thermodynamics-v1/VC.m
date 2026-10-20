function [ VC ] = VC( K,FAR,A,Pt,Tt,W,D)
%根据绝热指数、油气比、面积等计算气体速度系数
%Velocity Coefficient Function
%输入参数
% K     绝热指数
% FAR   油气比
% A     面积
% Pt    总压
% Tt    总温
% W     流量
%输出参数
% VC    速度系数
%计算临界面积
Wcor=W*(Tt)^0.5/Pt;
Ac=Wcor/FC(1.0,K,FAR,D);
if(A<Ac)
%截面达到临界状态
VC=1.0;
elseif(Pt>0 && W>0 && Tt>0)
F=@(VC) FC(VC,K,FAR,D)*A/Wcor-1;
X=[0,1.0];
VC=fzero(F,X);
else
VC=0;
end
end
    
