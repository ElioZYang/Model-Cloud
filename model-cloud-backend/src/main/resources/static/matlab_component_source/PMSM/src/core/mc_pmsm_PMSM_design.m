function motorModel=mc_pmsm_PMSM_design(configuration,power_kw,speed_rpm)
[c,op]=mc_pmsm_c_prepare_design(configuration,power_kw,speed_rpm,0);
[c,g]=mc_pmsm_c_dimensions(c,op);
[g,s,w]=mc_pmsm_c_stator(c,op,g);
[g,mag]=mc_pmsm_c_rotor(c,op,g,s);
[g,mass]=mc_pmsm_c_mass(c,op,g,s,w,mag);
losses=mc_pmsm_c_losses(c,op,g,s,w,mag,mass);
performance=mc_pmsm_c_performance(c,op,g,w,mass,losses);
motorModel=mc_pmsm_c_assemble(c,g,s,w,mag,mass,losses,performance);
end
