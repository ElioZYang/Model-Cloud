function scan_state = component_engine_envelope_append_point(scan_state, OP)
%COMPONENT_ENGINE_ENVELOPE_APPEND_POINT Append raw OP fields exactly.
scan_state.THRUST_ARRAY = [scan_state.THRUST_ARRAY, OP.THRUST];
scan_state.TIT_ARRAY = [scan_state.TIT_ARRAY, OP.TO(1)];
scan_state.COMP_WP = [scan_state.COMP_WP, OP.COMP_WP];
scan_state.TURB_WP = [scan_state.TURB_WP, OP.TURB_WP];
scan_state.MOTOR_WP = [scan_state.MOTOR_WP, OP.MOTOR_WP];
if isfield(OP,'pmsmSolverDiagnostics')
    if ~isfield(scan_state,'pmsmSolverDiagnostics'), scan_state.pmsmSolverDiagnostics=struct([]); end
    scan_state.pmsmSolverDiagnostics=[scan_state.pmsmSolverDiagnostics,OP.pmsmSolverDiagnostics];
end
end
