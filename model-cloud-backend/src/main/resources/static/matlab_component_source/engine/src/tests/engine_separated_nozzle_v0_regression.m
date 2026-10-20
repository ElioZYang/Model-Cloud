function report = engine_separated_nozzle_v0_regression()
%ENGINE_SEPARATED_NOZZLE_V0_REGRESSION Cover separated bypass nozzle inputs.
% The original source defines two axis-efficiency entries for its three-axis
% separated model. Match the approved platform template in test data only.
configs = {'separated turbofan', '2 spool separated turbofan', ...
    '3 spool separated turbofan', 'CFM56', 'mixed turbofan'};
report = repmat(struct('configuration', '', 'mode', '', ...
    'designPassed', false, 'offdesignPassed', false), 1, numel(configs) + 1);
entry = 0;
for k = 1:numel(configs)
    entry = entry + 1;
    report(entry) = engine_check_nozzle_speed(configs{k}, 60, 0, 'speed');
end
entry = entry + 1;
report(entry) = engine_check_nozzle_speed('separated turbofan', -1, 0.3, 'mach');
end

function result = engine_check_nozzle_speed(configuration, V, M, mode)
DP = struct('V', V, 'M', M, 'H', 3000, 'V_max', 60, ...
    'H_max', 3000, 'type', configuration);
DP = INPUT_DESIGN_PARAMETERS(DP);
DP.display = 0;
DP.V_max = 60;
DP.H_max = 3000;
DP.PWG = zeros(1, DP.NS);
if strcmp(configuration, '3 spool separated turbofan')
    DP.E_mech = [0.985; 0.985; 0.985];
    DP.E_motor = [0.97, 0.97, 0.97];
end

[DP, XD] = BALANCE_FUNCTION_DESIGN(DP, 0); %#ok<ASGLU>
assert(isfield(DP, 'YD'));
assert(isfinite(DP.V) && DP.V > 0);
if strcmp(mode, 'mach')
    assert(abs(DP.M - M) <= 1e-12);
end

OP = DP;
[OP, X0, DX] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, 0); %#ok<ASGLU>
assert(isfinite(OP.V) && OP.V > 0);
result = struct('configuration', configuration, 'mode', mode, ...
    'designPassed', true, 'offdesignPassed', true);
end
