function state = mc_pmsm_losses_performance(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'D_ir'), D_ir=state.D_ir; end
if isfield(state,'D_or'), D_or=state.D_or; end
if isfield(state,'E_ph'), E_ph=state.E_ph; end
if isfield(state,'I_ph'), I_ph=state.I_ph; end
if isfield(state,'L'), L=state.L; end
if isfield(state,'P_bearing'), P_bearing=state.P_bearing; end
if isfield(state,'P_cu'), P_cu=state.P_cu; end
if isfield(state,'P_fe'), P_fe=state.P_fe; end
if isfield(state,'P_loss'), P_loss=state.P_loss; end
if isfield(state,'P_mag'), P_mag=state.P_mag; end
if isfield(state,'P_mech'), P_mech=state.P_mech; end
if isfield(state,'P_rated'), P_rated=state.P_rated; end
if isfield(state,'P_stray'), P_stray=state.P_stray; end
if isfield(state,'P_windage'), P_windage=state.P_windage; end
if isfield(state,'R_ph'), R_ph=state.R_ph; end
if isfield(state,'V_ph'), V_ph=state.V_ph; end
if isfield(state,'a'), a=state.a; end
if isfield(state,'cal_mode'), cal_mode=state.cal_mode; end
if isfield(state,'cp_air'), cp_air=state.cp_air; end
if isfield(state,'eta'), eta=state.eta; end
if isfield(state,'gap'), gap=state.gap; end
if isfield(state,'mu_air'), mu_air=state.mu_air; end
if isfield(state,'omega'), omega=state.omega; end
if isfield(state,'rho_air'), rho_air=state.rho_air; end
    cp_air=1005;
    rho_air=1.29;
    mu_air=1.81e-5;
    [P_windage]=mc_pmsm_calculate_windage_losses(rho_air,mu_air,omega,D_or,D_ir,L,gap);
    P_bearing = 0;

    % 5-9. 总损耗
    P_loss = P_cu + P_fe + P_mag + P_windage + P_bearing + P_stray ;
    
    % 5-10. 更新效率和电流
    switch cal_mode
        case 0
    eta = 1;
    P_mech=0;
        case 1 % 发电机模式
    P_mech=P_rated+P_loss;
    eta = P_rated / P_mech;
    E_ph=V_ph+I_ph/a*R_ph;
    
        case -1% 电动机模式
    P_mech=P_rated-P_loss;
    eta = P_mech / P_rated ;
    E_ph=V_ph-I_ph/a*R_ph;
    end


if exist('E_ph','var') && ~isa(E_ph,'function_handle'), state.E_ph=E_ph; end
if exist('P_bearing','var') && ~isa(P_bearing,'function_handle'), state.P_bearing=P_bearing; end
if exist('P_loss','var') && ~isa(P_loss,'function_handle'), state.P_loss=P_loss; end
if exist('P_mech','var') && ~isa(P_mech,'function_handle'), state.P_mech=P_mech; end
if exist('P_windage','var') && ~isa(P_windage,'function_handle'), state.P_windage=P_windage; end
if exist('cp_air','var') && ~isa(cp_air,'function_handle'), state.cp_air=cp_air; end
if exist('eta','var') && ~isa(eta,'function_handle'), state.eta=eta; end
if exist('mu_air','var') && ~isa(mu_air,'function_handle'), state.mu_air=mu_air; end
if exist('rho_air','var') && ~isa(rho_air,'function_handle'), state.rho_air=rho_air; end
end
