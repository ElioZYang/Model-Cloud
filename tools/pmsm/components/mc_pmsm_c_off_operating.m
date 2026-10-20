function operatingPoint=mc_pmsm_c_off_operating(motorModel,power_kw,speed_rpm)
mc_pmsm_validate_operating(power_kw,speed_rpm);
c=motorModel.input; w=motorModel.winding; t=motorModel.thermal;
temp=t.temp_values(strcmpi(t.temp_variables,'temp_Cu'));
f=w.pole_pairs*speed_rpm/60; P=abs(power_kw)*1000; s=sign(power_kw);
rho=c.rho_Cu*(1+c.alpha_Cu*(temp-20)); Aw=pi/4*w.wire_dia^2*1e-6;
R=mc_pmsm_calculate_copper_resistance(w.wire_dia,f,temp,rho,w.conductors_per_slot,...
    motorModel.slot.area/1e6,Aw,motorModel.slot.slot_fill)*w.conductor_length_per_phase;
E=motorModel.performance.electro_potential*(speed_rpm/motorModel.performance.rated_speed);
if s==1, I=(E-(E^2-4*P*(R/c.a)/c.N_phase/c.cos_phi)^.5)/2/(R/c.a); V=E-I*R;
else, I=(-E+(E^2+4*P*(R/c.a)/c.N_phase/c.cos_phi)^.5)/2/(R/c.a); V=E+I*R; end
operatingPoint=struct('power_kw',power_kw,'power_W',P,'speed_rpm',speed_rpm,'electricMode',s,...
    'frequency_Hz',f,'current_A',I,'voltage_phase',V,'resistance_per_phase',R);
end
