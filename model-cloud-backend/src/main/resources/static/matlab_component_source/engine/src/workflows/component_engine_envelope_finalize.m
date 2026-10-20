function [MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = ...
    component_engine_envelope_finalize(scan_state)
%COMPONENT_ENGINE_ENVELOPE_FINALIZE Return the original envelope outputs.
cleanup = component_engine_envelope_scope(); %#ok<NASGU>
if ~isstruct(scan_state) || ~isfield(scan_state, 'DP')
    error('engine:InvalidScanState', 'scan_state is incomplete.');
end
MISSION = component_engine_envelope_mission(scan_state);
THRUST_ARRAY = scan_state.THRUST_ARRAY;
TIT_ARRAY = scan_state.TIT_ARRAY;
COMP_WP = scan_state.COMP_WP;
TURB_WP = scan_state.TURB_WP;
MOTOR_WP = scan_state.MOTOR_WP;
OP = scan_state.OP;
X0 = scan_state.X0;
DX = scan_state.DX;
end
