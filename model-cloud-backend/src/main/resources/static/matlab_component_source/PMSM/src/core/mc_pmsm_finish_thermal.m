function state = mc_pmsm_finish_thermal(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'C_cgv'), C_cgv=state.C_cgv; end
if isfield(state,'EFF'), EFF=state.EFF; end
if isfield(state,'H_cgv'), H_cgv=state.H_cgv; end
if isfield(state,'INPUT'), INPUT=state.INPUT; end
if isfield(state,'M_in'), M_in=state.M_in; end
if isfield(state,'N_slot'), N_slot=state.N_slot; end
if isfield(state,'OUTPUT'), OUTPUT=state.OUTPUT; end
if isfield(state,'P'), P=state.P; end
if isfield(state,'Q_Cu'), Q_Cu=state.Q_Cu; end
if isfield(state,'Q_Fe'), Q_Fe=state.Q_Fe; end
if isfield(state,'R'), R=state.R; end
if isfield(state,'Re_cgv'), Re_cgv=state.Re_cgv; end
if isfield(state,'Ro'), Ro=state.Ro; end
if isfield(state,'T'), T=state.T; end
if isfield(state,'T1'), T1=state.T1; end
if isfield(state,'TPR'), TPR=state.TPR; end
if isfield(state,'TPR0'), TPR0=state.TPR0; end
if isfield(state,'T_thermal_balance'), T_thermal_balance=state.T_thermal_balance; end
if isfield(state,'Vel'), Vel=state.Vel; end
if isfield(state,'WCOR'), WCOR=state.WCOR; end
if isfield(state,'WCOR0'), WCOR0=state.WCOR0; end
if isfield(state,'dP'), dP=state.dP; end
if isfield(state,'dT_air'), dT_air=state.dT_air; end
if isfield(state,'dT_pmsm_partial'), dT_pmsm_partial=state.dT_pmsm_partial; end
if isfield(state,'mode'), mode=state.mode; end
if isfield(state,'pmsm_params'), pmsm_params=state.pmsm_params; end
if isfield(state,'rhos'), rhos=state.rhos; end
T1=T+dT_air*EFF;
%% 计算总压损失
switch mode
    case "design"   
[dP] = mc_pmsm_calculate_annular_cascade_loss(...
    Vel, 2*Ro, 2*Ro+2*H_cgv, ...
    N_slot, H_cgv, 0, ...
    C_cgv, Re_cgv, M_in, ...
     0, 0, rhos);
TPR=1-dP/P*EFF;
    case "offdesign"
WCOR0=INPUT.WCOR;
TPR0=INPUT.TPR;
TPR=1-(1-TPR0)*(WCOR/WCOR0)^2*EFF;
end
% 计算出口参数
OUTPUT.T=T1;
OUTPUT.P=P*TPR;
OUTPUT.TPR=TPR;
OUTPUT.WCOR=WCOR;
OUTPUT.pmsm_params.thermal.thermal_resistance=R;
OUTPUT.pmsm_params.thermal.temp_balance=T_thermal_balance-273;
OUTPUT.pmsm_params.thermal.dT_air=dT_air*EFF;
OUTPUT.pmsm_params.thermal.dT_pmsm_partial=dT_pmsm_partial;
OUTPUT.pmsm_params.thermal.dH_pmsm_partial=[Q_Fe;Q_Cu].*dT_pmsm_partial/1000;
if exist('OUTPUT','var') && ~isa(OUTPUT,'function_handle'), state.OUTPUT=OUTPUT; end
if exist('T1','var') && ~isa(T1,'function_handle'), state.T1=T1; end
if exist('TPR','var') && ~isa(TPR,'function_handle'), state.TPR=TPR; end
if exist('TPR0','var') && ~isa(TPR0,'function_handle'), state.TPR0=TPR0; end
if exist('WCOR0','var') && ~isa(WCOR0,'function_handle'), state.WCOR0=WCOR0; end
if exist('dP','var') && ~isa(dP,'function_handle'), state.dP=dP; end
end
