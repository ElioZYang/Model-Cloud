function Rhp = mc_pmsm_ind_R_heatpipe(L_e,L_iso,L_c,HPWidth,HPthick)
%弦长确定后，热管的宽度和厚度也确定，可以计算热管的热阻等参数。
%热管的总宽度=0.5x导叶弦长；热管总厚度=0.5x导叶厚度=0.5x0.08x导叶弦长:
%假设总厚度：壳体：毛细芯：蒸发腔=2：3：3；
%注：计算量为一半的热管
HPLength=L_e/2+L_iso+L_c/2;
% HPWidth=0.45*C_cgv;
% HPthick=0.5*0.08*C_cgv;
ShThick=1/4*HPthick/2;
WickThick=3/8*HPthick/2;
VaporThick=3/8*HPthick/2;
%热管物性参数
k_shell=237;  %W/(m·K) 壳体导叶系数 铝
k_wick=5.6;   %%W/(m·K) 毛细芯导热系数 铝
Rgas=8.134;    % J/（gK）工质气体常数
T_vapor=372;   %蒸汽温度，K
miuv=1.67*10^(-5);   %蒸汽工质黏度系数 （kg/（m.s））
Hfg=2243.9e3;    %蒸汽汽化潜热 kJ/kg
Pv=0.2e6;        %蒸汽压力 MPa
rouV=1.155;  %蒸汽密度，kg/m3
%
Rshe=ShThick./k_shell./(L_e.*HPWidth);  % 蒸发端 热管壳体厚度方向热阻
Rshc=ShThick./k_shell./(L_c.*HPWidth);  % 冷凝端 热管壳体厚度方向热阻
Rh=HPLength./k_shell./(ShThick.*HPWidth);    %热管壳体长度方向热阻
Rwicke=WickThick./k_wick./(L_e.*HPWidth);   %蒸发段 毛细芯厚度方向热阻
Rwickc=WickThick./k_wick./(L_c.*HPWidth);   %冷凝段 毛细芯厚度方向热阻
Rcond=12*Rgas*T_vapor^2*miuv.*HPLength./(Hfg^2*Pv*rouV.*HPWidth.*VaporThick);   % 蒸汽腔热阻
Re=Rgas*T_vapor^2*(2*pi*Rgas*T_vapor)^0.5/Pv/Hfg^2/(L_e.*HPWidth);
Rc=Rgas*T_vapor^2*(2*pi*Rgas*T_vapor)^0.5/Pv/Hfg^2/(L_c.*HPWidth);
Ri=Rwicke+Re+Rcond+Rc+Rwickc+.5*(Rshe+Rshc);
Rhp=.5*(Rshe+Rshc)+(Rh*Ri)/(Rh+Ri);
end