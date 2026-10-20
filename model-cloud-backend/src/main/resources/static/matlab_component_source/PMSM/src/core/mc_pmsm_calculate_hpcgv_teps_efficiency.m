clc
clear
close all
t0=300;
effc=0.8;
efft=0.9;
effm=0.98;
prc=3.5;
prt=prc*0.95;
cp=1005;
t4=1350;
k=1.4;
k1=(k-1)/k;
kc=1+(prc^k1-1)/effc;
kt=1+(prt^-k1-1)*efft;
pw_rated=100e3;
pw=teg(1,t0,t4,kc,kt,effm);
[pw,wf]=teg(pw_rated/pw,t0,t4,kc,kt,effm);
disp("--conventional--")
fprintf("power=%2f(kW)\n",pw/1000)
fprintf("fuel consumption rate=%f(kg/s)\n",wf)
pw1=hpcgv_teg(1,t0,t4,kc,kt,effm);
[pw1,wf1]=hpcgv_teg(pw_rated/pw1,t0,t4,kc,kt,effm);
disp("--hpcgv teg--")
fprintf("power=%2f(kW)\n",pw1/1000)
fprintf("fuel consumption rate=%f(kg/s)\n",wf1)
function[pw,wf]=teg(wa,t0,t4,kc,kt,effm)
% 计算pw的解析表达式
% 输入参数：
%   t0: 进口温度
%   t4: 涡轮前温度
%   cp: 比热容
%   wa: 空气流量
%   effm: 机械效率
%   effb: 燃烧效率
%   hu: 燃料热值
%   kc: 压气机温升系数
%   kt: 涡轮降温系数
% 输出：
%   pw: 功率
%   wf: 燃油流量
cp=1005;
hu=43e6;
effb=0.99;
dt=0;
t1=t0+dt;
t2=kc*t1;
far=cp*(t4-t2)/(effb*hu-cp*t4);
wf=wa*far;
pw=cp*wa*((1+far)*(1-kt)*t4-(kc-1)*t1)*effm;
end
function[pw,wf]=hpcgv_teg(wa,t0,t4,kc,kt,effm)
% 计算pw的解析表达式
% 输入参数：
%   t0: 进口温度
%   t4: 涡轮前温度
%   cp: 比热容
%   wa: 空气流量
%   effm: 机械效率
%   effb: 燃烧效率
%   hu: 燃料热值
%   kc: 压气机温升系数
%   kt: 涡轮降温系数
% 输出：
%   pw: 功率
%   wf: 燃油流量
cp=1005;
hu=43e6;
effb=0.99;
% 计算中间常数
B = effb * hu - cp * t4;
Q = effb * hu - cp * kc * t0;

% 计算分子
numerator_part1 = (1 - kt) * t4 * Q / B;
numerator_part2 = (kc - 1) * t0;
numerator = cp * wa * effm * (numerator_part1 - numerator_part2);

% 计算分母
denominator_part1 = cp * kc * (1 - kt) * t4 / B;
denominator_part2 = kc - 1;
denominator = 1 + effm * (1 - effm) * (denominator_part1 + denominator_part2);
% 计算pw
pw = numerator / denominator;
wf = (wa * cp * (t4 - kc * t0) - kc * (1 - effm) * pw) / B;
end