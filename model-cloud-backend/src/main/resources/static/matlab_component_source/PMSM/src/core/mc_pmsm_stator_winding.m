function state = mc_pmsm_stator_winding(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'A_slot_min'), A_slot_min=state.A_slot_min; end
if isfield(state,'A_wire'), A_wire=state.A_wire; end
if isfield(state,'B_g_pm'), B_g_pm=state.B_g_pm; end
if isfield(state,'B_tooth'), B_tooth=state.B_tooth; end
if isfield(state,'B_yoke'), B_yoke=state.B_yoke; end
if isfield(state,'D_is'), D_is=state.D_is; end
if isfield(state,'D_os'), D_os=state.D_os; end
if isfield(state,'I_ph'), I_ph=state.I_ph; end
if isfield(state,'L'), L=state.L; end
if isfield(state,'L_end_per_phase'), L_end_per_phase=state.L_end_per_phase; end
if isfield(state,'L_slot_per_phase'), L_slot_per_phase=state.L_slot_per_phase; end
if isfield(state,'L_total_per_phase'), L_total_per_phase=state.L_total_per_phase; end
if isfield(state,'N_cs'), N_cs=state.N_cs; end
if isfield(state,'P_cu'), P_cu=state.P_cu; end
if isfield(state,'P_fe'), P_fe=state.P_fe; end
if isfield(state,'P_rated'), P_rated=state.P_rated; end
if isfield(state,'P_stray'), P_stray=state.P_stray; end
if isfield(state,'Q'), Q=state.Q; end
if isfield(state,'R_ac'), R_ac=state.R_ac; end
if isfield(state,'R_ph'), R_ph=state.R_ph; end
if isfield(state,'V_tooth'), V_tooth=state.V_tooth; end
if isfield(state,'V_yoke'), V_yoke=state.V_yoke; end
if isfield(state,'X_tooth'), X_tooth=state.X_tooth; end
if isfield(state,'X_yoke'), X_yoke=state.X_yoke; end
if isfield(state,'a'), a=state.a; end
if isfield(state,'alpha_Cu'), alpha_Cu=state.alpha_Cu; end
if isfield(state,'d_wire'), d_wire=state.d_wire; end
if isfield(state,'f_elec'), f_elec=state.f_elec; end
if isfield(state,'h_yoke'), h_yoke=state.h_yoke; end
if isfield(state,'k_fe'), k_fe=state.k_fe; end
if isfield(state,'m'), m=state.m; end
if isfield(state,'m_tooth'), m_tooth=state.m_tooth; end
if isfield(state,'m_yoke'), m_yoke=state.m_yoke; end
if isfield(state,'material_data'), material_data=state.material_data; end
if isfield(state,'pole_pairs'), pole_pairs=state.pole_pairs; end
if isfield(state,'rho_Cu'), rho_Cu=state.rho_Cu; end
if isfield(state,'rho_Cu_oper'), rho_Cu_oper=state.rho_Cu_oper; end
if isfield(state,'slot_fill'), slot_fill=state.slot_fill; end
if isfield(state,'slot_params'), slot_params=state.slot_params; end
if isfield(state,'stator_density'), stator_density=state.stator_density; end
if isfield(state,'temp_Cu'), temp_Cu=state.temp_Cu; end
if isfield(state,'temp_Fe'), temp_Fe=state.temp_Fe; end
%% 槽形优化设计

% mc_pmsm_calculate_slot_geometry_new...
%     (D_is,D_os,A_slot_min, ...
% Q,p,k_fe,slot_fill, ...
% X_tooth,X_yoke,...
% B_g,B_tooth,B_yoke)
[slot_params,D_os] = mc_pmsm_calculate_slot_geometry_new...
    (D_is,D_os,A_slot_min, ...
Q,pole_pairs,k_fe,slot_fill, ...
X_tooth,X_yoke,...
B_g_pm,B_tooth,B_yoke);
A_wire=slot_params.area_body*slot_fill/N_cs/1e6;
d_wire=2*(A_wire/pi)^.5*1e3;

    % 计算工作温度下的电阻
    rho_Cu_oper = rho_Cu * (1 + alpha_Cu*(temp_Cu - 20));
    
    % 计算每相绕组长度 (铁芯长度+端部)
    L_slot_per_phase=N_cs*Q*L/m;% 槽内绕组长度
%     L_end_per_phase=pi*N_cs*Q/m*((D_os-2*h_yoke+D_is)/4*sin(pi/N_cs)+h_yoke/2);% 端部绕组长度
    L_end_per_phase=.1*L_slot_per_phase;
    L_total_per_phase = L_slot_per_phase + L_end_per_phase; % 每相总长度

%     R_ph = (rho_Cu_oper  * L_total_per_phase) / A_wire ;
    
    [R_ac] = mc_pmsm_calculate_copper_resistance(...
        d_wire, f_elec, temp_Cu, rho_Cu_oper, ...
        N_cs, slot_params.area/1e6, A_wire, slot_params.slot_fill);
    
    R_ph = R_ac * L_total_per_phase;
    % 5-4. 铜耗计算
    P_cu = m * (I_ph/a)^2 * R_ph;
    h_yoke=slot_params.yoke_height/1000;
    V_yoke = (pi/4 * (D_os^2 - (D_os - 2*h_yoke)^2)) * L;
    V_tooth = (pi/4*(D_os^2-D_is^2)*L - slot_params.area/1e6*Q*L)  - V_yoke;
    % stator_density = material_data.('density (kg/m^3)')(strcmp(material_data.material, 'steel'));
    m_tooth=V_tooth*stator_density;
    m_yoke=V_yoke*stator_density;
    % 5-5. 铁耗计算 (改进Steinmetz模型)
%     mc_pmsm_calculate_iron_losses(D_os, D_is, Q, L, slot, k_fe,B_g, f, p, pole_type,temp_Fe)
    [P_fe] = mc_pmsm_calculate_iron_losses( D_is, Q,L, ...
    slot_params, k_fe,B_g_pm, f_elec, pole_pairs,temp_Fe,m_tooth,m_yoke);% 5-6. 机械损耗 (风摩损耗)
    
    % 5-7. 杂散负载损耗 (IEC标准)
    P_stray=mc_pmsm_calculate_extra_losses(P_rated);
%     P_stray=0;
    % 5-8. 永磁体涡流损耗 (待完善)

if exist('A_wire','var') && ~isa(A_wire,'function_handle'), state.A_wire=A_wire; end
if exist('D_os','var') && ~isa(D_os,'function_handle'), state.D_os=D_os; end
if exist('L_end_per_phase','var') && ~isa(L_end_per_phase,'function_handle'), state.L_end_per_phase=L_end_per_phase; end
if exist('L_slot_per_phase','var') && ~isa(L_slot_per_phase,'function_handle'), state.L_slot_per_phase=L_slot_per_phase; end
if exist('L_total_per_phase','var') && ~isa(L_total_per_phase,'function_handle'), state.L_total_per_phase=L_total_per_phase; end
if exist('P_cu','var') && ~isa(P_cu,'function_handle'), state.P_cu=P_cu; end
if exist('P_fe','var') && ~isa(P_fe,'function_handle'), state.P_fe=P_fe; end
if exist('P_stray','var') && ~isa(P_stray,'function_handle'), state.P_stray=P_stray; end
if exist('R_ac','var') && ~isa(R_ac,'function_handle'), state.R_ac=R_ac; end
if exist('R_ph','var') && ~isa(R_ph,'function_handle'), state.R_ph=R_ph; end
if exist('V_tooth','var') && ~isa(V_tooth,'function_handle'), state.V_tooth=V_tooth; end
if exist('V_yoke','var') && ~isa(V_yoke,'function_handle'), state.V_yoke=V_yoke; end
if exist('d_wire','var') && ~isa(d_wire,'function_handle'), state.d_wire=d_wire; end
if exist('h_yoke','var') && ~isa(h_yoke,'function_handle'), state.h_yoke=h_yoke; end
if exist('m_tooth','var') && ~isa(m_tooth,'function_handle'), state.m_tooth=m_tooth; end
if exist('m_yoke','var') && ~isa(m_yoke,'function_handle'), state.m_yoke=m_yoke; end
if exist('rho_Cu_oper','var') && ~isa(rho_Cu_oper,'function_handle'), state.rho_Cu_oper=rho_Cu_oper; end
if exist('slot_params','var') && ~isa(slot_params,'function_handle'), state.slot_params=slot_params; end
end
