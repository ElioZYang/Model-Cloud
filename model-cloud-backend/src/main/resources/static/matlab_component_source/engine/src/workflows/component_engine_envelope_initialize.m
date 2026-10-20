function scan_state = component_engine_envelope_initialize(DP)
%COMPONENT_ENGINE_ENVELOPE_INITIALIZE Initialize the legacy envelope scan.
% The first OFFDESIGN call deliberately discards its DX output, as in
% TURBOSHAFT_MAIN.  DX starts at zero and is retained for the power scan.
cleanup = component_engine_envelope_scope(); %#ok<NASGU>
if ~isstruct(DP)
    error('engine:InvalidDP', 'DP must be a struct.');
end

scan_state = component_engine_envelope_empty_state(DP, READMAP(DP));
scan_state.OP = DP;
scan_state.X0 = 0;
scan_state.DX = 0;
[scan_state.OP, scan_state.X0, ~, init] = ...
    BALANCE_FUNCTION_OFFDESIGN(DP, scan_state.OP, scan_state.X0);
scan_state.initialization = init;
scan_state.phase = 'initialized';
end

function scan_state = component_engine_envelope_empty_state(DP, MAP)
scan_state = struct('DP', DP, 'MAP', MAP, 'OP', DP, 'X0', 0, 'DX', 0, ...
    'THRUST_ARRAY', [], 'TIT_ARRAY', [], 'COMP_WP', [], ...
    'TURB_WP', [], 'MOTOR_WP', [], 'phase', 'created');
end
