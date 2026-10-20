clc
clear
close all
cd('..\');
ADD_PATH_ENGINE
DP.F="fan";
DP.NF=1;
DP.NS=1;
MAP=READMAP(DP);
% INPUT DESIGN PARAMETERS
PR0=2;
EFF0=0.8;
WA0=1;
N0=1;
WA_extraction=0;
V0=0;
H0=0;
FAR=0;
D=0;
DT=0;
QP=100;
% DUCT FAN DESIGN
I_inlet.WA=WA0;
I_inlet.FAR=0;
I_inlet.H=H0;
I_inlet.V=V0;
I_inlet.DT=DT;
I_inlet.QP=QP;
I_inlet.D=D;
O=INLET(I_inlet);
I_fan=O;
I_fan.PR=PR0;
I_fan.EFF=EFF0;
I_fan.WA_extraction=WA_extraction;
I_fan.N=N0;
I_fan.mode="design";
O=COMPRESSOR(I_fan);
O=FAN(O);
DP.THRUST=O.THRUST;
DP.PWC=O.PWC;
DP.WAC=O.WAC;
DP.NC0=O.NC0;
% DUCT FAN OFFDESIGN
