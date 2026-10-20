function losses=mc_pmsm_c_losses(configuration,operatingPoint,geometry,slot,winding,magnet,mass)
c=configuration; op=operatingPoint;
Pcu=c.N_phase*(op.current_A/c.a)^2*winding.resistance_per_phase;
t=c.thermal.temp_values(strcmpi(c.thermal.temp_variables,'temp_Fe'));
Pfe=mc_pmsm_calculate_iron_losses(geometry.stator_ID/1000,geometry.slot_number,geometry.core_length/1000,...
    slot,c.K_stack,c.B_g/c.arc_factor,op.frequency_Hz,c.pole_pairs,t,mass.stator_tooth,mass.stator_yoke);
Ps=mc_pmsm_calculate_extra_losses(op.power_W);
Pm=mc_pmsm_calculate_magnet_losses_offdesign(magnet,op.frequency_Hz,c.B_g,op.speed_rpm);
Pw=mc_pmsm_calculate_windage_losses(1.29,1.81e-5,op.omega,geometry.rotor_OD/1000,...
    geometry.rotor_ID/1000,geometry.core_length/1000,geometry.air_gap/1000);
losses=struct('copper',Pcu,'iron',Pfe,'magnet',Pm,'windage',Pw,'bearing',0,'stray',Ps,...
    'total',Pcu+Pfe+Pm+Pw+0+Ps);
end
