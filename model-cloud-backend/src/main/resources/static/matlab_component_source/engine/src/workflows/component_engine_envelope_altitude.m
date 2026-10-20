function scan_state = component_engine_envelope_altitude(scan_state, altitude_points)
%COMPONENT_ENGINE_ENVELOPE_ALTITUDE Run the legacy decreasing-height scan.
cleanup = component_engine_envelope_scope(); %#ok<NASGU>
component_engine_envelope_validate_state(scan_state);
if nargin < 2 || isempty(altitude_points), altitude_points = 100; end
component_engine_envelope_validate_count(altitude_points, 'altitude_points');
n = round(altitude_points);
DP = scan_state.DP;
OP = scan_state.OP;
X0 = scan_state.X0;
DX = scan_state.DX;
for k = 1:n
    OP.H = OP.H - DP.H_max / n;
    OP.N_ref = -DP.N_ref;
    OP.PWG = DP.PWG;
    [OP, X0, DX] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0 + 0.0 * DX);
    scan_state = component_engine_envelope_append_point(scan_state, OP);
end
scan_state.OP = OP;
scan_state.X0 = X0;
scan_state.DX = DX;
scan_state.phase = 'altitude';
end
