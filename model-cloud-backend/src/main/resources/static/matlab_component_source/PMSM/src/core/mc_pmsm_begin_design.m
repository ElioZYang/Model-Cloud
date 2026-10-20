function state=mc_pmsm_begin_design(INPUT,B_g_override)
mc_pmsm_validate_operating(INPUT.PWG,INPUT.NM);
if nargin>1&&B_g_override>0, INPUT.pmsm_input.B_g=B_g_override; end
state=struct('INPUT',INPUT,'pmsm_input',INPUT.pmsm_input,...
    'P_rated',INPUT.PWG,'n_rated',INPUT.NM);
end
