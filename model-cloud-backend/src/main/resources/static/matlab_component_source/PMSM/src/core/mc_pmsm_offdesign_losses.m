function state = mc_pmsm_offdesign_losses(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'B_g'), B_g=state.B_g; end
if isfield(state,'B_g_fe'), B_g_fe=state.B_g_fe; end
if isfield(state,'I_ph_offdesign'), I_ph_offdesign=state.I_ph_offdesign; end
if isfield(state,'K_arc'), K_arc=state.K_arc; end
if isfield(state,'P_cu'), P_cu=state.P_cu; end
if isfield(state,'P_fe'), P_fe=state.P_fe; end
if isfield(state,'P_loss'), P_loss=state.P_loss; end
if isfield(state,'P_mag'), P_mag=state.P_mag; end
if isfield(state,'P_mech'), P_mech=state.P_mech; end
if isfield(state,'P_offdesign'), P_offdesign=state.P_offdesign; end
if isfield(state,'P_stray'), P_stray=state.P_stray; end
if isfield(state,'P_windage'), P_windage=state.P_windage; end
if isfield(state,'R_ph'), R_ph=state.R_ph; end
if isfield(state,'V_ph_offdesign'), V_ph_offdesign=state.V_ph_offdesign; end
if isfield(state,'cal_mode'), cal_mode=state.cal_mode; end
if isfield(state,'eta'), eta=state.eta; end
if isfield(state,'f_elec_offdesign'), f_elec_offdesign=state.f_elec_offdesign; end
if isfield(state,'geometry'), geometry=state.geometry; end
if isfield(state,'input'), input=state.input; end
if isfield(state,'m'), m=state.m; end
if isfield(state,'mag_params'), mag_params=state.mag_params; end
if isfield(state,'mass'), mass=state.mass; end
if isfield(state,'n_offdesign'), n_offdesign=state.n_offdesign; end
if isfield(state,'n_rated'), n_rated=state.n_rated; end
if isfield(state,'pmsm_params_offdesign'), pmsm_params_offdesign=state.pmsm_params_offdesign; end
if isfield(state,'slot'), slot=state.slot; end
if isfield(state,'temp_Fe'), temp_Fe=state.temp_Fe; end
if isfield(state,'winding'), winding=state.winding; end
%% 非设计点损耗计算
% 1. 铜耗计算（考虑温度影响）
P_cu = m * (I_ph_offdesign/input.a)^2 * R_ph;

% 2. 铁耗计算（使用与设计点相同的计算方法）
% 计算非设计点气隙磁密
B_g=pmsm_params_offdesign.input.B_g;
% B_g_offdesign = pmsm_params_offdesign.input.B_g * (V_ph_offdesign/pmsm_params_offdesign.performance.voltage) * ...
%                (pmsm_params_offdesign.performance.speed/n_offdesign);
K_arc = pmsm_params_offdesign.input.arc_factor;
B_g_fe=B_g/K_arc;
% 使用与设计点相同的铁损计算函数

% [P_fe] = mc_pmsm_calculate_iron_losses( D_is, Q,L, ...
%     slot, k_fe,B_g, f, p,temp_Fe,m_tooth,m_yoke)

P_fe = mc_pmsm_calculate_iron_losses(...
    geometry.stator_ID/1000, ...
    geometry.slot_number, geometry.core_length/1000, ...
    slot,input.K_stack,B_g_fe, f_elec_offdesign, ...
    winding.pole_pairs,temp_Fe,mass.stator_tooth,mass.stator_yoke);

% 3. 机械损耗修正（转速立方关系）
P_windage = pmsm_params_offdesign.losses.windage * (n_offdesign/n_rated)^3;

% 4. 其他损耗（按比例估算）
% P_stray = 0;
P_stray = mc_pmsm_calculate_extra_losses(P_offdesign);  % 额定功率的0.5%
% 5. 磁钢损耗计算（使用与设计点相同的计算方法）
% 获取设计点磁钢参数

% 使用与设计点相同的磁损计算函数
P_mag=0;
% [P_mag] = mc_pmsm_calculate_magnet_losses_offdesign(...
%     mag_params, f_elec_offdesign, B_g, n_offdesign);
% 6. 总损耗与效率更新
P_loss = P_cu + P_fe + P_windage + pmsm_params_offdesign.losses.bearing + P_stray;

    switch cal_mode
        case 0
    eta = 1;
    P_mech=0;
        case 1
    P_mech=P_offdesign+P_loss;
    eta = P_offdesign / P_mech;
        case -1
    P_mech=P_offdesign-P_loss;
    eta = P_offdesign / P_mech ;
    end


if exist('B_g','var') && ~isa(B_g,'function_handle'), state.B_g=B_g; end
if exist('B_g_fe','var') && ~isa(B_g_fe,'function_handle'), state.B_g_fe=B_g_fe; end
if exist('K_arc','var') && ~isa(K_arc,'function_handle'), state.K_arc=K_arc; end
if exist('P_cu','var') && ~isa(P_cu,'function_handle'), state.P_cu=P_cu; end
if exist('P_fe','var') && ~isa(P_fe,'function_handle'), state.P_fe=P_fe; end
if exist('P_loss','var') && ~isa(P_loss,'function_handle'), state.P_loss=P_loss; end
if exist('P_mag','var') && ~isa(P_mag,'function_handle'), state.P_mag=P_mag; end
if exist('P_mech','var') && ~isa(P_mech,'function_handle'), state.P_mech=P_mech; end
if exist('P_stray','var') && ~isa(P_stray,'function_handle'), state.P_stray=P_stray; end
if exist('P_windage','var') && ~isa(P_windage,'function_handle'), state.P_windage=P_windage; end
if exist('eta','var') && ~isa(eta,'function_handle'), state.eta=eta; end
end
