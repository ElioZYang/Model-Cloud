function performance=mc_pmsm_c_off_performance(motorModel,operatingPoint,losses)
op=operatingPoint; P=op.power_W; s=op.electricMode;
% Preserve the engine's offdesign convention, including its >1 efficiency
% for motoring. The public feasibility check reports this native limitation.
if s==1, Pm=P+losses.total; eta=P/Pm; else, Pm=P-losses.total; eta=P/Pm; end
performance=motorModel.performance;
performance.speed=op.speed_rpm; performance.power=s*P; performance.mechanical_power=s*Pm;
performance.efficiency=eta; performance.voltage=op.voltage_phase; performance.current=op.current_A;
performance.current_density=op.current_A/(pi*(motorModel.winding.wire_dia/2000)^2)/1e6;
end
