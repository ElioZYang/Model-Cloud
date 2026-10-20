function state = mc_pmsm_prepare_thermal(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'A_slot'), A_slot=state.A_slot; end
if isfield(state,'A_stator'), A_stator=state.A_stator; end
if isfield(state,'Area'), Area=state.Area; end
if isfield(state,'C_cgv'), C_cgv=state.C_cgv; end
if isfield(state,'D'), D=state.D; end
if isfield(state,'D_hpcgv'), D_hpcgv=state.D_hpcgv; end
if isfield(state,'EFF'), EFF=state.EFF; end
if isfield(state,'FAR'), FAR=state.FAR; end
if isfield(state,'H_cgv'), H_cgv=state.H_cgv; end
if isfield(state,'H_open'), H_open=state.H_open; end
if isfield(state,'H_slot'), H_slot=state.H_slot; end
if isfield(state,'INPUT'), INPUT=state.INPUT; end
if isfield(state,'K'), K=state.K; end
if isfield(state,'L'), L=state.L; end
if isfield(state,'M_in'), M_in=state.M_in; end
if isfield(state,'M_in0'), M_in0=state.M_in0; end
if isfield(state,'N_slot'), N_slot=state.N_slot; end
if isfield(state,'OUTPUT'), OUTPUT=state.OUTPUT; end
if isfield(state,'P'), P=state.P; end
if isfield(state,'Ps_amb'), Ps_amb=state.Ps_amb; end
if isfield(state,'Rho'), Rho=state.Rho; end
if isfield(state,'Ri'), Ri=state.Ri; end
if isfield(state,'Ro'), Ro=state.Ro; end
if isfield(state,'Rri'), Rri=state.Rri; end
if isfield(state,'Rro'), Rro=state.Rro; end
if isfield(state,'T'), T=state.T; end
if isfield(state,'T_Cu'), T_Cu=state.T_Cu; end
if isfield(state,'T_Fe'), T_Fe=state.T_Fe; end
if isfield(state,'T_magnet'), T_magnet=state.T_magnet; end
if isfield(state,'Ts_amb'), Ts_amb=state.Ts_amb; end
if isfield(state,'Vel'), Vel=state.Vel; end
if isfield(state,'W'), W=state.W; end
if isfield(state,'WA'), WA=state.WA; end
if isfield(state,'WCOR'), WCOR=state.WCOR; end
if isfield(state,'Wb'), Wb=state.Wb; end
if isfield(state,'Wt'), Wt=state.Wt; end
if isfield(state,'choke'), choke=state.choke; end
if isfield(state,'cooling'), cooling=state.cooling; end
if isfield(state,'fun'), fun=state.fun; end
if isfield(state,'g'), g=state.g; end
if isfield(state,'k_cavity'), k_cavity=state.k_cavity; end
if isfield(state,'k_cu'), k_cu=state.k_cu; end
if isfield(state,'k_housing'), k_housing=state.k_housing; end
if isfield(state,'k_iso'), k_iso=state.k_iso; end
if isfield(state,'k_slot'), k_slot=state.k_slot; end
if isfield(state,'k_stator'), k_stator=state.k_stator; end
if isfield(state,'material_data'), material_data=state.material_data; end
if isfield(state,'mode'), mode=state.mode; end
if isfield(state,'omega'), omega=state.omega; end
if isfield(state,'pmsm_params'), pmsm_params=state.pmsm_params; end
if isfield(state,'rhos'), rhos=state.rhos; end
if isfield(state,'slot_fill'), slot_fill=state.slot_fill; end
if isfield(state,'t_iso'), t_iso=state.t_iso; end
if isfield(state,'temp_Cu'), temp_Cu=state.temp_Cu; end
if isfield(state,'temp_Fe'), temp_Fe=state.temp_Fe; end
if isfield(state,'temp_magnet'), temp_magnet=state.temp_magnet; end
if isfield(state,'temp_values'), temp_values=state.temp_values; end
if isfield(state,'temp_variables'), temp_variables=state.temp_variables; end
if isfield(state,'theta'), theta=state.theta; end
if isfield(state,'theta0'), theta0=state.theta0; end
if isfield(state,'theta1'), theta1=state.theta1; end
if isfield(state,'theta2'), theta2=state.theta2; end
if isfield(state,'v_rotor'), v_rotor=state.v_rotor; end
OUTPUT=INPUT;
pmsm_params=INPUT.pmsm_params;
cooling=pmsm_params.input.cooling;
mode=INPUT.mode;
%% 输入进气参数
T=INPUT.T;% 总温
P=INPUT.P;% 总压
FAR=INPUT.FAR;% 油气比
D=INPUT.D;% 湿度
WA=INPUT.WA;% 空气流量
EFF=INPUT.EFFH;
W=WA*(1+FAR);
if W<=0
    warning("no airflow")
end
K=mc_pmsm_AE(T,FAR,D);
WCOR=W*sqrt(T)/P;
%% 输入电机参数
% 关键节点温度
% 温度变量
temp_variables=pmsm_params.thermal.temp_variables;
temp_values=pmsm_params.thermal.temp_values;
temp_Fe=temp_values(strcmpi(temp_variables,'temp_Fe'));
temp_Cu=temp_values(strcmpi(temp_variables,'temp_Cu'));
temp_magnet=temp_values(strcmpi(temp_variables,'temp_magnet'));
T_Cu=temp_Cu+273;
T_Fe=temp_Fe+273;
T_magnet=temp_magnet+273;
% 几何参数
Rri=pmsm_params.geometry.rotor_ID/2000; % 转子内径（m）
Rro=pmsm_params.geometry.rotor_OD/2000;% 转子外径（m）
g=pmsm_params.geometry.air_gap/1000;% 气隙长度（m）
Ri=pmsm_params.geometry.stator_ID/2000; % 定子内径（m）
Ro=pmsm_params.geometry.stator_OD/2000;% 定子外径（m）
Rho=pmsm_params.geometry.housing_OD/2000;% 机壳外径（m）
L=pmsm_params.geometry.core_length/1000;% 核心长度（m）
N_slot=pmsm_params.geometry.slot_number;
slot_fill=pmsm_params.slot.slot_fill;
H_slot=pmsm_params.slot.total_depth/1000;
H_open=pmsm_params.slot.opening_height/1000;
A_slot=pmsm_params.slot.area/1e6/2;
A_stator=pi*(Ro^2-Ri^2)/N_slot/2-A_slot;
Wt=pmsm_params.slot.tooth_width/1000;
Wb=pmsm_params.slot.bottom_width/1000;
% 电机转速
omega=pmsm_params.performance.speed*pi/30;
v_rotor=omega*Rro;
% 特征扇形区域夹角
theta=2*pi/2/N_slot;
theta0=Wb/(Ri+H_slot)/2;
theta1=theta-theta0;
theta2=Wt/(Ri)/2;
% 导叶高度
H_cgv=pmsm_params.geometry.cgv_height/1000;
% 导叶长度
C_cgv=pmsm_params.geometry.cgv_length/1000;
Area=pi*((Rho+H_cgv)^2-Rho^2);% 通流面积

% 材料导热系数 (W/(m·K))
material_data = pmsm_params.input.material.data;
% 创建材料属性查找函数
t_iso=0.2*1e-3;
k_iso = mc_pmsm_get_prop(material_data,'iso', 'thermal_conductivity');
k_cu = mc_pmsm_get_prop(material_data,'copper', 'thermal_conductivity');
k_stator = mc_pmsm_get_prop(material_data,'steel', 'thermal_conductivity');
k_housing = mc_pmsm_get_prop(material_data,'aluminum', 'thermal_conductivity');
k_cavity = mc_pmsm_get_prop(material_data,'cavity', 'thermal_conductivity');
k_slot=k_cu*slot_fill+k_cavity*(1-slot_fill);

%% 计算来流静参数
M_in0=W*(mc_pmsm_GC(FAR,D)*T/K)^.5/Area/P;
fun=@(M_in) Area*M_in*mc_pmsm_SV(T/(1+(K-1)/2*M_in^2),FAR,D)...
    *(P/T/mc_pmsm_GC(FAR,D))*(1+(K-1)/2*M_in^2)^(1-K/(K-1))/W-1;
choke=fun(1);
if choke<0
    warning("hpcgv choke!")
    M_in=1;
    W=W*(choke+1);
    WA=WA*(choke+1);
else
M_in=fzero(fun,M_in0);
end
Ts_amb=T/(1+(K-1)/2*M_in^2);
Ps_amb=P/(1+(K-1)/2*M_in^2)^(K/(K-1));
Vel=M_in*mc_pmsm_SV(Ts_amb,FAR,D);
rhos=Ps_amb/mc_pmsm_GC(FAR,D)/Ts_amb;
if mode=="design"
D_hpcgv=2*(Rho+H_cgv);
OUTPUT.pmsm_params.geometry.AN=Area;
OUTPUT.pmsm_params.geometry.hpcgv_OD=D_hpcgv*1000;
end

if exist('A_slot','var') && ~isa(A_slot,'function_handle'), state.A_slot=A_slot; end
if exist('A_stator','var') && ~isa(A_stator,'function_handle'), state.A_stator=A_stator; end
if exist('Area','var') && ~isa(Area,'function_handle'), state.Area=Area; end
if exist('C_cgv','var') && ~isa(C_cgv,'function_handle'), state.C_cgv=C_cgv; end
if exist('D','var') && ~isa(D,'function_handle'), state.D=D; end
if exist('D_hpcgv','var') && ~isa(D_hpcgv,'function_handle'), state.D_hpcgv=D_hpcgv; end
if exist('EFF','var') && ~isa(EFF,'function_handle'), state.EFF=EFF; end
if exist('FAR','var') && ~isa(FAR,'function_handle'), state.FAR=FAR; end
if exist('H_cgv','var') && ~isa(H_cgv,'function_handle'), state.H_cgv=H_cgv; end
if exist('H_open','var') && ~isa(H_open,'function_handle'), state.H_open=H_open; end
if exist('H_slot','var') && ~isa(H_slot,'function_handle'), state.H_slot=H_slot; end
if exist('K','var') && ~isa(K,'function_handle'), state.K=K; end
if exist('L','var') && ~isa(L,'function_handle'), state.L=L; end
if exist('M_in','var') && ~isa(M_in,'function_handle'), state.M_in=M_in; end
if exist('M_in0','var') && ~isa(M_in0,'function_handle'), state.M_in0=M_in0; end
if exist('N_slot','var') && ~isa(N_slot,'function_handle'), state.N_slot=N_slot; end
if exist('OUTPUT','var') && ~isa(OUTPUT,'function_handle'), state.OUTPUT=OUTPUT; end
if exist('P','var') && ~isa(P,'function_handle'), state.P=P; end
if exist('Ps_amb','var') && ~isa(Ps_amb,'function_handle'), state.Ps_amb=Ps_amb; end
if exist('Rho','var') && ~isa(Rho,'function_handle'), state.Rho=Rho; end
if exist('Ri','var') && ~isa(Ri,'function_handle'), state.Ri=Ri; end
if exist('Ro','var') && ~isa(Ro,'function_handle'), state.Ro=Ro; end
if exist('Rri','var') && ~isa(Rri,'function_handle'), state.Rri=Rri; end
if exist('Rro','var') && ~isa(Rro,'function_handle'), state.Rro=Rro; end
if exist('T','var') && ~isa(T,'function_handle'), state.T=T; end
if exist('T_Cu','var') && ~isa(T_Cu,'function_handle'), state.T_Cu=T_Cu; end
if exist('T_Fe','var') && ~isa(T_Fe,'function_handle'), state.T_Fe=T_Fe; end
if exist('T_magnet','var') && ~isa(T_magnet,'function_handle'), state.T_magnet=T_magnet; end
if exist('Ts_amb','var') && ~isa(Ts_amb,'function_handle'), state.Ts_amb=Ts_amb; end
if exist('Vel','var') && ~isa(Vel,'function_handle'), state.Vel=Vel; end
if exist('W','var') && ~isa(W,'function_handle'), state.W=W; end
if exist('WA','var') && ~isa(WA,'function_handle'), state.WA=WA; end
if exist('WCOR','var') && ~isa(WCOR,'function_handle'), state.WCOR=WCOR; end
if exist('Wb','var') && ~isa(Wb,'function_handle'), state.Wb=Wb; end
if exist('Wt','var') && ~isa(Wt,'function_handle'), state.Wt=Wt; end
if exist('choke','var') && ~isa(choke,'function_handle'), state.choke=choke; end
if exist('cooling','var') && ~isa(cooling,'function_handle'), state.cooling=cooling; end
if exist('fun','var') && ~isa(fun,'function_handle'), state.fun=fun; end
if exist('g','var') && ~isa(g,'function_handle'), state.g=g; end
if exist('k_cavity','var') && ~isa(k_cavity,'function_handle'), state.k_cavity=k_cavity; end
if exist('k_cu','var') && ~isa(k_cu,'function_handle'), state.k_cu=k_cu; end
if exist('k_housing','var') && ~isa(k_housing,'function_handle'), state.k_housing=k_housing; end
if exist('k_iso','var') && ~isa(k_iso,'function_handle'), state.k_iso=k_iso; end
if exist('k_slot','var') && ~isa(k_slot,'function_handle'), state.k_slot=k_slot; end
if exist('k_stator','var') && ~isa(k_stator,'function_handle'), state.k_stator=k_stator; end
if exist('material_data','var') && ~isa(material_data,'function_handle'), state.material_data=material_data; end
if exist('mode','var') && ~isa(mode,'function_handle'), state.mode=mode; end
if exist('omega','var') && ~isa(omega,'function_handle'), state.omega=omega; end
if exist('pmsm_params','var') && ~isa(pmsm_params,'function_handle'), state.pmsm_params=pmsm_params; end
if exist('rhos','var') && ~isa(rhos,'function_handle'), state.rhos=rhos; end
if exist('slot_fill','var') && ~isa(slot_fill,'function_handle'), state.slot_fill=slot_fill; end
if exist('t_iso','var') && ~isa(t_iso,'function_handle'), state.t_iso=t_iso; end
if exist('temp_Cu','var') && ~isa(temp_Cu,'function_handle'), state.temp_Cu=temp_Cu; end
if exist('temp_Fe','var') && ~isa(temp_Fe,'function_handle'), state.temp_Fe=temp_Fe; end
if exist('temp_magnet','var') && ~isa(temp_magnet,'function_handle'), state.temp_magnet=temp_magnet; end
if exist('temp_values','var') && ~isa(temp_values,'function_handle'), state.temp_values=temp_values; end
if exist('temp_variables','var') && ~isa(temp_variables,'function_handle'), state.temp_variables=temp_variables; end
if exist('theta','var') && ~isa(theta,'function_handle'), state.theta=theta; end
if exist('theta0','var') && ~isa(theta0,'function_handle'), state.theta0=theta0; end
if exist('theta1','var') && ~isa(theta1,'function_handle'), state.theta1=theta1; end
if exist('theta2','var') && ~isa(theta2,'function_handle'), state.theta2=theta2; end
if exist('v_rotor','var') && ~isa(v_rotor,'function_handle'), state.v_rotor=v_rotor; end
end
