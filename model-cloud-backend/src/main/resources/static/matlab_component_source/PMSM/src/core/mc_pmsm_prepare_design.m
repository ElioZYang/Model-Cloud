function state = mc_pmsm_prepare_design(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'B_g_eq'), B_g_eq=state.B_g_eq; end
if isfield(state,'B_g_pm'), B_g_pm=state.B_g_pm; end
if isfield(state,'B_tooth'), B_tooth=state.B_tooth; end
if isfield(state,'B_yoke'), B_yoke=state.B_yoke; end
if isfield(state,'D_is'), D_is=state.D_is; end
if isfield(state,'I_ph'), I_ph=state.I_ph; end
if isfield(state,'J_max'), J_max=state.J_max; end
if isfield(state,'K_arc'), K_arc=state.K_arc; end
if isfield(state,'K_carter'), K_carter=state.K_carter; end
if isfield(state,'K_winding'), K_winding=state.K_winding; end
if isfield(state,'N_cs'), N_cs=state.N_cs; end
if isfield(state,'P_rated'), P_rated=state.P_rated; end
if isfield(state,'Q'), Q=state.Q; end
if isfield(state,'T_rated'), T_rated=state.T_rated; end
if isfield(state,'V_ph'), V_ph=state.V_ph; end
if isfield(state,'XC_cgv'), XC_cgv=state.XC_cgv; end
if isfield(state,'XH_cgv'), XH_cgv=state.XH_cgv; end
if isfield(state,'X_length'), X_length=state.X_length; end
if isfield(state,'X_rotor'), X_rotor=state.X_rotor; end
if isfield(state,'X_stator'), X_stator=state.X_stator; end
if isfield(state,'X_tooth'), X_tooth=state.X_tooth; end
if isfield(state,'X_yoke'), X_yoke=state.X_yoke; end
if isfield(state,'a'), a=state.a; end
if isfield(state,'alpha_Cu'), alpha_Cu=state.alpha_Cu; end
if isfield(state,'aluminum_density'), aluminum_density=state.aluminum_density; end
if isfield(state,'cal_mode'), cal_mode=state.cal_mode; end
if isfield(state,'cavity_density'), cavity_density=state.cavity_density; end
if isfield(state,'cooling'), cooling=state.cooling; end
if isfield(state,'copper_density'), copper_density=state.copper_density; end
if isfield(state,'cos_phi'), cos_phi=state.cos_phi; end
if isfield(state,'f_elec'), f_elec=state.f_elec; end
if isfield(state,'gap'), gap=state.gap; end
if isfield(state,'h_yoke'), h_yoke=state.h_yoke; end
if isfield(state,'k_fe'), k_fe=state.k_fe; end
if isfield(state,'m'), m=state.m; end
if isfield(state,'mag_params'), mag_params=state.mag_params; end
if isfield(state,'magnet'), magnet=state.magnet; end
if isfield(state,'magnet_density'), magnet_density=state.magnet_density; end
if isfield(state,'material_data'), material_data=state.material_data; end
if isfield(state,'n_rated'), n_rated=state.n_rated; end
if isfield(state,'omega'), omega=state.omega; end
if isfield(state,'pmsm_input'), pmsm_input=state.pmsm_input; end
if isfield(state,'pole_pairs'), pole_pairs=state.pole_pairs; end
if isfield(state,'rho_Cu'), rho_Cu=state.rho_Cu; end
if isfield(state,'rotor_density'), rotor_density=state.rotor_density; end
if isfield(state,'slot_fill'), slot_fill=state.slot_fill; end
if isfield(state,'slot_pitch'), slot_pitch=state.slot_pitch; end
if isfield(state,'stator_density'), stator_density=state.stator_density; end
if isfield(state,'temp_Cu'), temp_Cu=state.temp_Cu; end
if isfield(state,'temp_Fe'), temp_Fe=state.temp_Fe; end
if isfield(state,'temp_magnet'), temp_magnet=state.temp_magnet; end
if isfield(state,'temp_values'), temp_values=state.temp_values; end
if isfield(state,'temp_variables'), temp_variables=state.temp_variables; end
% 优化版PMSM设计程序（含槽形优化）
% 主要改进：
% 1. 动态槽形设计（考虑齿部/轭部磁密约束）
% 2. 槽满率自动校验
% 3. 多物理场耦合迭代

%% 输入参数处理
cal_mode=sign(P_rated);
P_rated = abs(P_rated) * 1000; % 电功率（W）
V_ph=pmsm_input.voltage_phase;% 相电压
if V_ph<0
V_ph=pmsm_input.voltage_line/(3^0.5);
end
m=pmsm_input.N_phase;
%% 从input结构体获取所有参数
% 固定变量
cos_phi = pmsm_input.cos_phi;
K_winding = pmsm_input.K_w;
rho_Cu = pmsm_input.rho_Cu;
alpha_Cu = pmsm_input.alpha_Cu;
a = pmsm_input.a;% 并联支路数
% core_material = pmsm_input.core_material;
% cooling = pmsm_input.cooling;
k_fe = pmsm_input.K_stack;
gap = pmsm_input.h_airgap/1000;
B_g_eq = pmsm_input.B_g; 
K_arc = pmsm_input.arc_factor;
K_carter = pmsm_input.carter_factor;
B_g_pm = B_g_eq/K_arc;
X_tooth= pmsm_input.X_tooth;%b_tooth=X_tooth*t_s;
X_yoke= pmsm_input.X_yoke;%h_yoke=X_yoke*D_is/2;
B_tooth = pmsm_input.B_tooth;
B_yoke =pmsm_input.B_yoke;
N_cs = pmsm_input.N_cs;
slot_fill = pmsm_input.slot_fill;
J_max = pmsm_input.J_max;
pole_pairs = pmsm_input.pole_pairs;
Q = pmsm_input.N_slot;
slot_pitch = pmsm_input.slot_pitch/1e3;
X_stator=pmsm_input.X_stator;
X_length=pmsm_input.X_length;
X_rotor=pmsm_input.X_rotor;
cooling=pmsm_input.cooling;
XC_cgv=pmsm_input.XC_cgv;
XH_cgv=pmsm_input.XH_cgv;
material_data=pmsm_input.material.data;
% 温度变量
temp_variables=pmsm_input.thermal.temp_variables;
temp_values=pmsm_input.thermal.temp_values;
temp_Fe=temp_values(strcmpi(temp_variables,'temp_Fe'));
temp_Cu=temp_values(strcmpi(temp_variables,'temp_Cu'));
temp_magnet=temp_values(strcmpi(temp_variables,'temp_magnet'));
if n_rated > 5000
    magnet = 'SmCo';
else
    magnet = 'NdFeB';
end
mag_params.magnet_type=magnet;
% 密度参数获取（集中管理）
stator_density     = mc_pmsm_get_prop(material_data, 'steel', 'density');
rotor_density      = mc_pmsm_get_prop(material_data, 'steel_shaft', 'density');
copper_density     = mc_pmsm_get_prop(material_data, 'copper', 'density');
cavity_density     = mc_pmsm_get_prop(material_data, 'cavity', 'density');
magnet_density     = mc_pmsm_get_prop(material_data, magnet, 'density');
aluminum_density   = mc_pmsm_get_prop(material_data, 'aluminum', 'density');

omega=n_rated*pi/30;
%% 基础参数计算
% fprintf('\n=== PMSM优化设计启动 ===\n');
T_rated = P_rated / omega;  % 额定转矩(N·m)
f_elec = pole_pairs * n_rated / 60;              % 电频率(Hz)
I_ph = P_rated / (m * V_ph  * cos_phi); % 相电流

if exist('B_g_eq','var') && ~isa(B_g_eq,'function_handle'), state.B_g_eq=B_g_eq; end
if exist('B_g_pm','var') && ~isa(B_g_pm,'function_handle'), state.B_g_pm=B_g_pm; end
if exist('B_tooth','var') && ~isa(B_tooth,'function_handle'), state.B_tooth=B_tooth; end
if exist('B_yoke','var') && ~isa(B_yoke,'function_handle'), state.B_yoke=B_yoke; end
if exist('I_ph','var') && ~isa(I_ph,'function_handle'), state.I_ph=I_ph; end
if exist('J_max','var') && ~isa(J_max,'function_handle'), state.J_max=J_max; end
if exist('K_arc','var') && ~isa(K_arc,'function_handle'), state.K_arc=K_arc; end
if exist('K_carter','var') && ~isa(K_carter,'function_handle'), state.K_carter=K_carter; end
if exist('K_winding','var') && ~isa(K_winding,'function_handle'), state.K_winding=K_winding; end
if exist('N_cs','var') && ~isa(N_cs,'function_handle'), state.N_cs=N_cs; end
if exist('P_rated','var') && ~isa(P_rated,'function_handle'), state.P_rated=P_rated; end
if exist('Q','var') && ~isa(Q,'function_handle'), state.Q=Q; end
if exist('T_rated','var') && ~isa(T_rated,'function_handle'), state.T_rated=T_rated; end
if exist('V_ph','var') && ~isa(V_ph,'function_handle'), state.V_ph=V_ph; end
if exist('XC_cgv','var') && ~isa(XC_cgv,'function_handle'), state.XC_cgv=XC_cgv; end
if exist('XH_cgv','var') && ~isa(XH_cgv,'function_handle'), state.XH_cgv=XH_cgv; end
if exist('X_length','var') && ~isa(X_length,'function_handle'), state.X_length=X_length; end
if exist('X_rotor','var') && ~isa(X_rotor,'function_handle'), state.X_rotor=X_rotor; end
if exist('X_stator','var') && ~isa(X_stator,'function_handle'), state.X_stator=X_stator; end
if exist('X_tooth','var') && ~isa(X_tooth,'function_handle'), state.X_tooth=X_tooth; end
if exist('X_yoke','var') && ~isa(X_yoke,'function_handle'), state.X_yoke=X_yoke; end
if exist('a','var') && ~isa(a,'function_handle'), state.a=a; end
if exist('alpha_Cu','var') && ~isa(alpha_Cu,'function_handle'), state.alpha_Cu=alpha_Cu; end
if exist('aluminum_density','var') && ~isa(aluminum_density,'function_handle'), state.aluminum_density=aluminum_density; end
if exist('cal_mode','var') && ~isa(cal_mode,'function_handle'), state.cal_mode=cal_mode; end
if exist('cavity_density','var') && ~isa(cavity_density,'function_handle'), state.cavity_density=cavity_density; end
if exist('cooling','var') && ~isa(cooling,'function_handle'), state.cooling=cooling; end
if exist('copper_density','var') && ~isa(copper_density,'function_handle'), state.copper_density=copper_density; end
if exist('cos_phi','var') && ~isa(cos_phi,'function_handle'), state.cos_phi=cos_phi; end
if exist('f_elec','var') && ~isa(f_elec,'function_handle'), state.f_elec=f_elec; end
if exist('gap','var') && ~isa(gap,'function_handle'), state.gap=gap; end
if exist('k_fe','var') && ~isa(k_fe,'function_handle'), state.k_fe=k_fe; end
if exist('m','var') && ~isa(m,'function_handle'), state.m=m; end
if exist('mag_params','var') && ~isa(mag_params,'function_handle'), state.mag_params=mag_params; end
if exist('magnet','var') && ~isa(magnet,'function_handle'), state.magnet=magnet; end
if exist('magnet_density','var') && ~isa(magnet_density,'function_handle'), state.magnet_density=magnet_density; end
if exist('material_data','var') && ~isa(material_data,'function_handle'), state.material_data=material_data; end
if exist('omega','var') && ~isa(omega,'function_handle'), state.omega=omega; end
if exist('pole_pairs','var') && ~isa(pole_pairs,'function_handle'), state.pole_pairs=pole_pairs; end
if exist('rho_Cu','var') && ~isa(rho_Cu,'function_handle'), state.rho_Cu=rho_Cu; end
if exist('rotor_density','var') && ~isa(rotor_density,'function_handle'), state.rotor_density=rotor_density; end
if exist('slot_fill','var') && ~isa(slot_fill,'function_handle'), state.slot_fill=slot_fill; end
if exist('slot_pitch','var') && ~isa(slot_pitch,'function_handle'), state.slot_pitch=slot_pitch; end
if exist('stator_density','var') && ~isa(stator_density,'function_handle'), state.stator_density=stator_density; end
if exist('temp_Cu','var') && ~isa(temp_Cu,'function_handle'), state.temp_Cu=temp_Cu; end
if exist('temp_Fe','var') && ~isa(temp_Fe,'function_handle'), state.temp_Fe=temp_Fe; end
if exist('temp_magnet','var') && ~isa(temp_magnet,'function_handle'), state.temp_magnet=temp_magnet; end
if exist('temp_values','var') && ~isa(temp_values,'function_handle'), state.temp_values=temp_values; end
if exist('temp_variables','var') && ~isa(temp_variables,'function_handle'), state.temp_variables=temp_variables; end
end
