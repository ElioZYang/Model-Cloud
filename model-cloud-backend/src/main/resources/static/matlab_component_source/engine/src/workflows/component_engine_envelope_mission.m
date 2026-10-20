function MISSION = component_engine_envelope_mission(scan_state)
%COMPONENT_ENGINE_ENVELOPE_MISSION Build the legacy MISSION structure.
MISSION = struct();
MISSION.G = struct('DP', scan_state.DP, 'MAP', scan_state.MAP, ...
    'COMP_WP', scan_state.COMP_WP, 'TURB_WP', scan_state.TURB_WP, ...
    'MOTOR_WP', scan_state.MOTOR_WP);
if isfield(scan_state,'pmsmSolverDiagnostics')
    MISSION.G.pmsmSolverDiagnostics=scan_state.pmsmSolverDiagnostics;
end
end
