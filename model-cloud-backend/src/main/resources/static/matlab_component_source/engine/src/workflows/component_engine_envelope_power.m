function [scan_state, MISSION_power] = component_engine_envelope_power(scan_state, power_points)
%COMPONENT_ENGINE_ENVELOPE_POWER Run the legacy decreasing-power scan.
cleanup = component_engine_envelope_scope(); %#ok<NASGU>
component_engine_envelope_validate_state(scan_state);
if nargin < 2 || isempty(power_points), power_points = 20; end
component_engine_envelope_validate_count(power_points, 'power_points');
n = round(power_points);
DP = scan_state.DP;
OP = scan_state.OP;
X0 = scan_state.X0;
DX = scan_state.DX;
pwg_array = linspace(1, .01, n);
for k = 1:n
    OP.N_ref = -DP.N_ref;
    OP.PWG(1) = DP.PWG(1);
    OP.PWG(1) = pwg_array(k) * DP.PWG(1);
    [OP, X0, DX] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0 + 0.0 * DX);
    scan_state = component_engine_envelope_append_point(scan_state, OP);
end
scan_state.OP = OP;
scan_state.X0 = X0;
scan_state.DX = DX;
scan_state.phase = 'power';
MISSION_power = component_engine_envelope_mission(scan_state);
end
