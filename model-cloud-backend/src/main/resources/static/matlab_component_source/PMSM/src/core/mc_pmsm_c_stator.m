function [geometry,slot,winding]=mc_pmsm_c_stator(configuration,operatingPoint,geometry)
c=configuration; op=operatingPoint;
Di=geometry.stator_ID/1000; Do=geometry.stator_OD/1000; L=geometry.core_length/1000;
Q=geometry.slot_number; N=c.N_cs;
[~,Aw]=mc_pmsm_calculate_wire_diameter(op.current_A/c.a,c.J_max);
minimum=N*Aw/c.slot_fill;
[slot,Do]=mc_pmsm_calculate_slot_geometry_new(Di,Do,minimum,Q,c.pole_pairs,c.K_stack,...
    c.slot_fill,c.X_tooth,c.X_yoke,c.B_g/c.arc_factor,c.B_tooth,c.B_yoke);
Aw=slot.area_body*c.slot_fill/N/1e6; diameter=2*(Aw/pi)^.5*1e3;
Lslot=N*Q*L/c.N_phase; Ltotal=Lslot+.1*Lslot;
t=c.thermal.temp_values(strcmpi(c.thermal.temp_variables,'temp_Cu'));
rho=c.rho_Cu*(1+c.alpha_Cu*(t-20));
Rac=mc_pmsm_calculate_copper_resistance(diameter,op.frequency_Hz,t,rho,N,slot.area/1e6,Aw,slot.slot_fill);
geometry.stator_OD=Do*1000;
winding=struct('pole_pairs',c.pole_pairs,'conductors_per_slot',N,'wire_dia',diameter,...
    'parallel_paths',c.a,'conductor_length_per_phase',Ltotal,'resistance_per_phase',Rac*Ltotal,'connection','star');
end
