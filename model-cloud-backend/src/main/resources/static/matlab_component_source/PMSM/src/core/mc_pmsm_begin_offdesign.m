function state=mc_pmsm_begin_offdesign(INPUT)
power=INPUT.PWG*INPUT.PWG_ref; speed=INPUT.NM*INPUT.N_ref;
mc_pmsm_validate_operating(power,speed);
state=struct('INPUT',INPUT,'pmsm_params_offdesign',INPUT.pmsm_input,...
    'P_offdesign',power,'n_offdesign',speed);
end
