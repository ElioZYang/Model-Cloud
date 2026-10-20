function motorModel=mc_pmsm_PMSM_off_design(designModel,power_kw,speed_rpm)
op=mc_pmsm_c_off_operating(designModel,power_kw,speed_rpm);
losses=mc_pmsm_c_off_losses(designModel,op);
performance=mc_pmsm_c_off_performance(designModel,op,losses);
motorModel=mc_pmsm_c_off_assemble(designModel,losses,performance);
end
