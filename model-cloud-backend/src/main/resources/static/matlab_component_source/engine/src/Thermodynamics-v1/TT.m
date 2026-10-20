function [ T1 ] = TT( Hs,FAR )
%根据气体比焓、油气比和绝对湿度计算气体温度
%Total Temperature
%输入参数
% Hs    比焓
% FAR   油气比
%输出参数
% T1     温度
T1=(Hs/9.80665)/1048.0*4185.7666/427.0;
% D_h=1000;
% i=1;
fun=@(T) 1-SE(T,FAR)/Hs;
T1=fzero(fun,T1);
% while(abs(D_h)>=0.0001*Hs) 
%    h_x=SE(T1,FAR);
%    D_h=Hs-h_x;
%    T1=T1+(D_h/9.80665)/0.2504/427.0;
%    i=i+1;
%    if i>200
%        return
%    end
% end
end

