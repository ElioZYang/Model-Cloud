function [ Cp ] = CPSH(T,FAR)
%根据温度、油气比与绝对湿度计算气体的定压比热
%Constant Pressure Specific Heat
%输入参数
% T     温度
% FAR   油气比
%输出参数
% Cp    定压比热
A = [ 2.5020051e-1,-9.2766377e-05, 2.12283126e-07,-3.91784261e-11,...
    -1.588103965e-13, 1.44014858e-16,-4.94087671e-20, 6.19293505e-24];
B = [7.38166347e-02, 2.20655334e-03,-4.4620956e-06,5.81373326e-09,...
    -4.41435621e-12, 1.9297991e-15,-4.53575645e-19,  4.44953549e-23];
% cpa=0;
% cpf=0;
% for i=1:8
%     cpa=cpa+A(i)*(T^(i-1));
%     cpf=cpf+B(i)*(T^(i-1));
% end
T_array = T.^(linspace(0,7,8)');
cpa = A*T_array;
cpf = B*T_array;
Cp  = (cpa + FAR*cpf)./(1 + FAR).*427.*9.80665;

% obj=1，比焓
% obj=2，定压比热容
% obj=3，熵函数
% fun=1，空气
% fun=2，ceta函数
% fun=3，水蒸气
% Cp_g=PRO(T,2,1)+FAR/(1+FAR)*PRO(T,2,2);
% Cp_h=PRO(T,2,3);
% Cp=((1+FAR)*Cp_g+G*Cp_h)/(1+FAR+G);
end

