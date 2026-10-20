function[MAP]=TURBO_GENERATOR_MAP(DP,MAP)
NH=MAP.TURBO_GENERATOR.N_alt;
NV=MAP.TURBO_GENERATOR.N_vel;
NP=MAP.TURBO_GENERATOR.N_pwg;
NT=MAP.TURBO_GENERATOR.N_thrust;
P_min=MAP.TURBO_GENERATOR.P_min;
P_max=MAP.TURBO_GENERATOR.P_max;	
T_min=MAP.TURBO_GENERATOR.T_min;
T_max=MAP.TURBO_GENERATOR.T_max;	
H_array=linspace(0,1,NH);
V_array=linspace(0,1,NV);
P_array=1;
T_array=1;
if P_max==1&&P_min==1
elseif P_min==1
P_array=linspace(1,P_max,NP);
elseif P_max==1
NP1=ceil(NP*(1-P_min)/0.1);
P_array=linspace(P_min,1,NP1);
else
P_array_acc=linspace(1,P_max,NP);
NP1=ceil(NP*(1-P_min)/(P_max-1));
P_array_dcc=linspace(P_min,1,NP1);
P_array=[P_array_dcc(1:end-1),P_array_acc];
end
NP=length(P_array);
if T_max==1&&T_min==1
elseif T_min==1
T_array=linspace(1,T_max,NP);
elseif T_max==1
NT1=ceil(NT*(1-T_min)/0.1);
T_array=linspace(T_min,1,NT1);
else
T_array_acc=linspace(1,T_max,NT);
NT1=ceil(NT*(1-T_min)/(T_max-1));
T_array_dcc=linspace(T_min,1,NT1);
T_array=[T_array_dcc(1:end-1),T_array_acc];
end
NT=length(T_array);
if NT>1&&NP>1
map_type=1;
elseif NT==1&&NP>1
map_type=2;
elseif NT>1&&NP==1
map_type=3;
else
map_type=4;
end
OP=DP;
[OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,0);
w=0.0;
dX_hv=0;
dX_pt=0;
switch map_type
    case 1 %H,V,P,T
        MAP_1
    case 2 %H,V,P
        MAP_2
    case 3 %H,V,T
        MAP_3
    case 4 %H,V
        MAP_4
end
MAP.TURBO_GENERATOR.V_ARRAY=V_array;
MAP.TURBO_GENERATOR.H_ARRAY=H_array;
MAP.TURBO_GENERATOR.PWG_ARRAY=P_array;
MAP.TURBO_GENERATOR.THRUST_ARRAY=T_array;
MAP.TURBO_GENERATOR.WF_ARRAY=WF_ARRAY;
MAP.TURBO_GENERATOR.type=map_type;
disp("---------------------")
disp("涡轮发电装置MAP图生成完成")
disp("MAP图类型")
disp(map_type)
disp("---------------------")
end