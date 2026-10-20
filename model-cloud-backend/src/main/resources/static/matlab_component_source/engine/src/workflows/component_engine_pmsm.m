function OUTPUT=component_engine_pmsm(INPUT,DP,motor_index)
% Invoke the current editable PMSM graph on every residual evaluation.
if ~isfield(DP,'motorProgramIds')||numel(DP.motorProgramIds)<motor_index
    error('engine:MissingMotorProgram','The detailed PMSM requires a compiled subsystem program.');
end
ids=string(DP.motorProgramIds);
OUTPUT=mc_pmsm_invoke(INPUT,char(ids(motor_index)));
end
