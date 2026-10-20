function [ T ] = mc_pmsm_TEMP( h,far )
%根据气体比焓、油气比和绝对湿度计算气体温度
%Temperature
%输入参数
% h     比焓
% far   油气比
%输出参数
% T     温度
T=(h/9.80665)/1048.0*4185.7666/427.0;
D_h=1000;
while(abs(D_h)>=0.0001*h) 
   h_x=mc_pmsm_SE(T,far);
   D_h=h-h_x;
   T=T+(D_h/9.80665)/0.2504/427.0;
end
end

