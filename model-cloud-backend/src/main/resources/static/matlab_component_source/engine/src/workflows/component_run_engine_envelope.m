function [MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = ...
    component_run_engine_envelope(DP, power_points, speed_points, altitude_points)
%COMPONENT_RUN_ENGINE_ENVELOPE Run the legacy envelope through thin stages.
% The nine outputs and solver exception behavior remain compatible with the
% original TURBOSHAFT_MAIN workflow.  Stage callers can retain scan_state
% and obtain MISSION_power from component_engine_envelope_power directly.
if nargin < 2 || isempty(power_points), power_points = 20; end
if nargin < 3 || isempty(speed_points), speed_points = 100; end
if nargin < 4 || isempty(altitude_points), altitude_points = 100; end

scan_state = component_engine_envelope_initialize(DP);
[scan_state, ~] = component_engine_envelope_power(scan_state, power_points);
scan_state = component_engine_envelope_speed_initialize(scan_state);
scan_state = component_engine_envelope_speed(scan_state, speed_points);
scan_state = component_engine_envelope_altitude(scan_state, altitude_points);
[MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = ...
    component_engine_envelope_finalize(scan_state);
end
