function state = mc_pmsm_mass_cooling(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'A_wire'), A_wire=state.A_wire; end
if isfield(state,'C_cgv'), C_cgv=state.C_cgv; end
if isfield(state,'D_ir'), D_ir=state.D_ir; end
if isfield(state,'D_oh'), D_oh=state.D_oh; end
if isfield(state,'D_or'), D_or=state.D_or; end
if isfield(state,'D_os'), D_os=state.D_os; end
if isfield(state,'H_cgv'), H_cgv=state.H_cgv; end
if isfield(state,'L'), L=state.L; end
if isfield(state,'L_total_per_phase'), L_total_per_phase=state.L_total_per_phase; end
if isfield(state,'P_loss'), P_loss=state.P_loss; end
if isfield(state,'P_rated'), P_rated=state.P_rated; end
if isfield(state,'Q'), Q=state.Q; end
if isfield(state,'V_housing'), V_housing=state.V_housing; end
if isfield(state,'V_rotor_core'), V_rotor_core=state.V_rotor_core; end
if isfield(state,'V_shaft'), V_shaft=state.V_shaft; end
if isfield(state,'XC_cgv'), XC_cgv=state.XC_cgv; end
if isfield(state,'XH_cgv'), XH_cgv=state.XH_cgv; end
if isfield(state,'aluminum_density'), aluminum_density=state.aluminum_density; end
if isfield(state,'cavity_density'), cavity_density=state.cavity_density; end
if isfield(state,'cooling'), cooling=state.cooling; end
if isfield(state,'copper_density'), copper_density=state.copper_density; end
if isfield(state,'cp_air'), cp_air=state.cp_air; end
if isfield(state,'m'), m=state.m; end
if isfield(state,'m_cavity'), m_cavity=state.m_cavity; end
if isfield(state,'m_cgv'), m_cgv=state.m_cgv; end
if isfield(state,'m_copper'), m_copper=state.m_copper; end
if isfield(state,'m_hex'), m_hex=state.m_hex; end
if isfield(state,'m_housing'), m_housing=state.m_housing; end
if isfield(state,'m_magnet'), m_magnet=state.m_magnet; end
if isfield(state,'m_rotor'), m_rotor=state.m_rotor; end
if isfield(state,'m_shaft'), m_shaft=state.m_shaft; end
if isfield(state,'m_stator'), m_stator=state.m_stator; end
if isfield(state,'m_tooth'), m_tooth=state.m_tooth; end
if isfield(state,'m_total'), m_total=state.m_total; end
if isfield(state,'m_yoke'), m_yoke=state.m_yoke; end
if isfield(state,'mag_params'), mag_params=state.mag_params; end
if isfield(state,'magnet_density'), magnet_density=state.magnet_density; end
if isfield(state,'power_density'), power_density=state.power_density; end
if isfield(state,'rho_air'), rho_air=state.rho_air; end
if isfield(state,'rotor_density'), rotor_density=state.rotor_density; end
if isfield(state,'shaft_extension'), shaft_extension=state.shaft_extension; end
if isfield(state,'slot_fill'), slot_fill=state.slot_fill; end
if isfield(state,'slot_params'), slot_params=state.slot_params; end
if isfield(state,'t_housing'), t_housing=state.t_housing; end
%% 重量计算
% 1. 定子铁芯重量计算
m_stator = m_tooth+m_yoke;
% 2. 转子铁芯重量计算
V_rotor_core = pi/4 * D_or^2 * L-mag_params.volume;
m_rotor = rotor_density * V_rotor_core; % kg

% 3. 绕组重量计算 (槽内+端部)
m_copper=copper_density*3*L_total_per_phase*A_wire;
m_cavity=cavity_density*slot_params.area/1e6*L*Q*(1-slot_fill);
% 4. 永磁体重量计算
m_magnet = magnet_density * mag_params.volume; % kg

% 5. 机壳重量计算 (假设机壳厚度10mm)
t_housing = 0.1*D_os; % 机壳厚度(m)
D_oh = D_os + 2*t_housing; % 机壳外径
V_housing = pi/4 * (D_oh^2 - D_os^2) * (L + 0.05)+pi/4*D_oh^2*2*t_housing; % 增加5cm长度余量
m_housing = aluminum_density * V_housing; % kg
m_hex=0;
m_cgv=0;
H_cgv=0.5*XH_cgv*D_oh;
C_cgv=XC_cgv*L;
switch cooling
    case {1,2} % (热管)导叶冷却
m_cgv=Q*H_cgv*C_cgv*0.06*C_cgv*aluminum_density;
    case 3 % 水冷
% PD_thx=0.68*(P_rated/1e6)^(1/3);
% PD_fan=0.2;
% dT_cooling=10;
% V_cooling=P_loss/(rho_air*cp_air*dT_cooling);
% dP_cooling=200;
% eta_fan=0.6;
% % m_hex=P_loss/1000/PD_thx;
% PW_fan=V_cooling*dP_cooling/eta_fan;
% m_coolingfan=PW_fan/1000/PD_fan;
m_hex=15*P_rated/1E5;
end
% 6. 轴重量计算 (假设轴伸出长度50mm/side)
shaft_extension = 0.05; % 单端伸出长度(m)
V_shaft = pi * (D_ir/2)^2 * (2*shaft_extension);
m_shaft = rotor_density * V_shaft; % kg

% 7. 总重量计算
m_total = m_stator + m_rotor + m_copper + m_cavity + m_magnet + m_housing + m_shaft+ m_cgv+ m_hex;

% 8. 功率密度计算 (kW/kg)
power_density = P_rated / 1000 / m_total;



if exist('C_cgv','var') && ~isa(C_cgv,'function_handle'), state.C_cgv=C_cgv; end
if exist('D_oh','var') && ~isa(D_oh,'function_handle'), state.D_oh=D_oh; end
if exist('H_cgv','var') && ~isa(H_cgv,'function_handle'), state.H_cgv=H_cgv; end
if exist('V_housing','var') && ~isa(V_housing,'function_handle'), state.V_housing=V_housing; end
if exist('V_rotor_core','var') && ~isa(V_rotor_core,'function_handle'), state.V_rotor_core=V_rotor_core; end
if exist('V_shaft','var') && ~isa(V_shaft,'function_handle'), state.V_shaft=V_shaft; end
if exist('m_cavity','var') && ~isa(m_cavity,'function_handle'), state.m_cavity=m_cavity; end
if exist('m_cgv','var') && ~isa(m_cgv,'function_handle'), state.m_cgv=m_cgv; end
if exist('m_copper','var') && ~isa(m_copper,'function_handle'), state.m_copper=m_copper; end
if exist('m_hex','var') && ~isa(m_hex,'function_handle'), state.m_hex=m_hex; end
if exist('m_housing','var') && ~isa(m_housing,'function_handle'), state.m_housing=m_housing; end
if exist('m_magnet','var') && ~isa(m_magnet,'function_handle'), state.m_magnet=m_magnet; end
if exist('m_rotor','var') && ~isa(m_rotor,'function_handle'), state.m_rotor=m_rotor; end
if exist('m_shaft','var') && ~isa(m_shaft,'function_handle'), state.m_shaft=m_shaft; end
if exist('m_stator','var') && ~isa(m_stator,'function_handle'), state.m_stator=m_stator; end
if exist('m_total','var') && ~isa(m_total,'function_handle'), state.m_total=m_total; end
if exist('power_density','var') && ~isa(power_density,'function_handle'), state.power_density=power_density; end
if exist('shaft_extension','var') && ~isa(shaft_extension,'function_handle'), state.shaft_extension=shaft_extension; end
if exist('t_housing','var') && ~isa(t_housing,'function_handle'), state.t_housing=t_housing; end
end
