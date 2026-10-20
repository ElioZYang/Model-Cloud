function state = mc_pmsm_prepare_offdesign(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'A_wire'), A_wire=state.A_wire; end
if isfield(state,'E_ph_offdesign'), E_ph_offdesign=state.E_ph_offdesign; end
if isfield(state,'I_ph_offdesign'), I_ph_offdesign=state.I_ph_offdesign; end
if isfield(state,'L_total_per_phase'), L_total_per_phase=state.L_total_per_phase; end
if isfield(state,'P_offdesign'), P_offdesign=state.P_offdesign; end
if isfield(state,'R_ac'), R_ac=state.R_ac; end
if isfield(state,'R_ph'), R_ph=state.R_ph; end
if isfield(state,'V_ph_offdesign'), V_ph_offdesign=state.V_ph_offdesign; end
if isfield(state,'cal_mode'), cal_mode=state.cal_mode; end
if isfield(state,'cos_phi'), cos_phi=state.cos_phi; end
if isfield(state,'f_elec_offdesign'), f_elec_offdesign=state.f_elec_offdesign; end
if isfield(state,'geometry'), geometry=state.geometry; end
if isfield(state,'input'), input=state.input; end
if isfield(state,'m'), m=state.m; end
if isfield(state,'mag_params'), mag_params=state.mag_params; end
if isfield(state,'mass'), mass=state.mass; end
if isfield(state,'n_offdesign'), n_offdesign=state.n_offdesign; end
if isfield(state,'n_rated'), n_rated=state.n_rated; end
if isfield(state,'pmsm_params_offdesign'), pmsm_params_offdesign=state.pmsm_params_offdesign; end
if isfield(state,'rho_Cu_oper'), rho_Cu_oper=state.rho_Cu_oper; end
if isfield(state,'slot'), slot=state.slot; end
if isfield(state,'temp_Cu'), temp_Cu=state.temp_Cu; end
if isfield(state,'temp_Fe'), temp_Fe=state.temp_Fe; end
if isfield(state,'temp_values'), temp_values=state.temp_values; end
if isfield(state,'temp_variables'), temp_variables=state.temp_variables; end
if isfield(state,'thermal'), thermal=state.thermal; end
if isfield(state,'winding'), winding=state.winding; end
% PMSM非设计点性能计算
% 输入：
%   motor_params_design - 设计点输出的完整结构体
%   P_offdesign - 非设计点功率 (kW)
%   n_offdesign - 非设计点转速 (rpm)
% 输出：
%   motor_params_offdesign - 非设计点参数结构体（与设计点结构体同构）
% pmsm_params_offdesign=pmsm_params_offdesign;
%% 初始化输出结构体（复制设计点固定参数）
% motor_params_offdesign = motor_params_design; % 继承所有固定参数
cal_mode = sign(P_offdesign);
P_offdesign = abs(P_offdesign) * 1000; % 功率单位转换为W

%% 从设计点结构体提取参数（保持变量名一致）
input = pmsm_params_offdesign.input;
geometry = pmsm_params_offdesign.geometry;
winding = pmsm_params_offdesign.winding;
mass = pmsm_params_offdesign.mass;
% materials = pmsm_params_offdesign.materials;
thermal = pmsm_params_offdesign.thermal;
slot=pmsm_params_offdesign.slot;
mag_params=pmsm_params_offdesign.magnet;
% magnet_geometry = motor_params_design.magnet_geometry;
% 温度变量
temp_variables=thermal.temp_variables;
temp_values=thermal.temp_values;
temp_Fe=temp_values(strcmpi(temp_variables,'temp_Fe'));
temp_Cu=temp_values(strcmpi(temp_variables,'temp_Cu'));
%% 非设计点基础计算
m=input.N_phase;
f_elec_offdesign = winding.pole_pairs * n_offdesign / 60; % 非设计点电频率[Hz]
n_rated = pmsm_params_offdesign.performance.rated_speed; % 设计点转速作为基速
%% 电压计算（考虑弱磁控制策略）
% 策略：低于基速时保持额定电压，高于基速时线性弱磁
rho_Cu_oper = input.rho_Cu * (1 + input.alpha_Cu*(temp_Cu - 20));
L_total_per_phase = pmsm_params_offdesign.winding.conductor_length_per_phase;
A_wire=pi/4*pmsm_params_offdesign.winding.wire_dia^2*1e-6;
    [R_ac] = mc_pmsm_calculate_copper_resistance(...
        winding.wire_dia, f_elec_offdesign, temp_Cu, rho_Cu_oper, ...
        winding.conductors_per_slot, slot.area/1e6, A_wire, slot.slot_fill);
    
    R_ph = R_ac * L_total_per_phase;

E_ph_offdesign = pmsm_params_offdesign.performance.electro_potential* (n_offdesign/n_rated); % 额定电动势
cos_phi=input.cos_phi;
switch cal_mode
    case 0
        I_ph_offdesign=0;
    case 1
        I_ph_offdesign=(E_ph_offdesign-(E_ph_offdesign^2-4*P_offdesign*(R_ph/input.a)/m/cos_phi)^.5)/2/(R_ph/input.a);
        V_ph_offdesign=E_ph_offdesign-I_ph_offdesign*R_ph;
    case -1
        I_ph_offdesign=(-E_ph_offdesign+(E_ph_offdesign^2+4*P_offdesign*(R_ph/input.a)/m/cos_phi)^.5)/2/(R_ph/input.a);
        V_ph_offdesign=E_ph_offdesign+I_ph_offdesign*R_ph;
end


if exist('A_wire','var') && ~isa(A_wire,'function_handle'), state.A_wire=A_wire; end
if exist('E_ph_offdesign','var') && ~isa(E_ph_offdesign,'function_handle'), state.E_ph_offdesign=E_ph_offdesign; end
if exist('I_ph_offdesign','var') && ~isa(I_ph_offdesign,'function_handle'), state.I_ph_offdesign=I_ph_offdesign; end
if exist('L_total_per_phase','var') && ~isa(L_total_per_phase,'function_handle'), state.L_total_per_phase=L_total_per_phase; end
if exist('P_offdesign','var') && ~isa(P_offdesign,'function_handle'), state.P_offdesign=P_offdesign; end
if exist('R_ac','var') && ~isa(R_ac,'function_handle'), state.R_ac=R_ac; end
if exist('R_ph','var') && ~isa(R_ph,'function_handle'), state.R_ph=R_ph; end
if exist('V_ph_offdesign','var') && ~isa(V_ph_offdesign,'function_handle'), state.V_ph_offdesign=V_ph_offdesign; end
if exist('cal_mode','var') && ~isa(cal_mode,'function_handle'), state.cal_mode=cal_mode; end
if exist('cos_phi','var') && ~isa(cos_phi,'function_handle'), state.cos_phi=cos_phi; end
if exist('f_elec_offdesign','var') && ~isa(f_elec_offdesign,'function_handle'), state.f_elec_offdesign=f_elec_offdesign; end
if exist('geometry','var') && ~isa(geometry,'function_handle'), state.geometry=geometry; end
if exist('input','var') && ~isa(input,'function_handle'), state.input=input; end
if exist('m','var') && ~isa(m,'function_handle'), state.m=m; end
if exist('mag_params','var') && ~isa(mag_params,'function_handle'), state.mag_params=mag_params; end
if exist('mass','var') && ~isa(mass,'function_handle'), state.mass=mass; end
if exist('n_rated','var') && ~isa(n_rated,'function_handle'), state.n_rated=n_rated; end
if exist('rho_Cu_oper','var') && ~isa(rho_Cu_oper,'function_handle'), state.rho_Cu_oper=rho_Cu_oper; end
if exist('slot','var') && ~isa(slot,'function_handle'), state.slot=slot; end
if exist('temp_Cu','var') && ~isa(temp_Cu,'function_handle'), state.temp_Cu=temp_Cu; end
if exist('temp_Fe','var') && ~isa(temp_Fe,'function_handle'), state.temp_Fe=temp_Fe; end
if exist('temp_values','var') && ~isa(temp_values,'function_handle'), state.temp_values=temp_values; end
if exist('temp_variables','var') && ~isa(temp_variables,'function_handle'), state.temp_variables=temp_variables; end
if exist('thermal','var') && ~isa(thermal,'function_handle'), state.thermal=thermal; end
if exist('winding','var') && ~isa(winding,'function_handle'), state.winding=winding; end
end
