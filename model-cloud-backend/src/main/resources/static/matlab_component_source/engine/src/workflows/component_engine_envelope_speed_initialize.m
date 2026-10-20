function scan_state = component_engine_envelope_speed_initialize(scan_state)
%COMPONENT_ENGINE_ENVELOPE_SPEED_INITIALIZE Reset before the speed scan.
cleanup = component_engine_envelope_scope(); %#ok<NASGU>
if ~isstruct(scan_state) || ~isfield(scan_state, 'DP')
    error('engine:InvalidScanState', 'scan_state is incomplete.');
end
DP = scan_state.DP;
OP = DP;
X0 = 0;
[OP, X0, ~, speed_init] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0);
scan_state.OP = OP;
scan_state.X0 = X0;
% The legacy reset discards the third output and leaves scan_state.DX from
% the power segment untouched.
scan_state.speed_initialization = speed_init;
scan_state.phase = 'speed_initialized';
end
