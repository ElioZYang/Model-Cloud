function losses=mc_pmsm_c_off_losses(motorModel,operatingPoint)
c=motorModel.input; g=motorModel.geometry; w=motorModel.winding; op=operatingPoint;
t=motorModel.thermal.temp_values(strcmpi(motorModel.thermal.temp_variables,'temp_Fe'));
Pcu=c.N_phase*(op.current_A/c.a)^2*op.resistance_per_phase;
Pfe=mc_pmsm_calculate_iron_losses(g.stator_ID/1000,g.slot_number,g.core_length/1000,...
    motorModel.slot,c.K_stack,c.B_g/c.arc_factor,op.frequency_Hz,w.pole_pairs,t,...
    motorModel.mass.stator_tooth,motorModel.mass.stator_yoke);
Pw=motorModel.losses.windage*(op.speed_rpm/motorModel.performance.rated_speed)^3;
Ps=mc_pmsm_calculate_extra_losses(op.power_W); Pb=motorModel.losses.bearing;
losses=struct('copper',Pcu,'iron',Pfe,'magnet',0,'windage',Pw,'bearing',Pb,'stray',Ps,...
    'total',Pcu+Pfe+Pw+Pb+Ps);
end
