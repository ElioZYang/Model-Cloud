function baseline = engine_legacy_baseline(reference_root, configuration, n_power, n_speed, n_altitude)
%ENGINE_LEGACY_BASELINE Capture the reference TURBOSHAFT_MAIN state machine.
% This helper is intentionally separate from the deployed workflows.  It is
% used by local regression tests with the untouched demo project.
if nargin < 2, configuration = "turboshaft"; end
if nargin < 3, n_power = 3; end
if nargin < 4, n_speed = 4; end
if nargin < 5, n_altitude = 4; end
old_directory = pwd;
old_path = path;
cleanup = onCleanup(@() engine_restore_baseline(old_directory, old_path)); %#ok<NASGU>
cd(reference_root);
ADD_PATH_ENGINE;

DP.V = 60; DP.M = 0; DP.H = 3000;
DP.V_max = 60; DP.H_max = 3000; DP.type = string(configuration);
DP = INPUT_DESIGN_PARAMETERS(DP);
DP.display = 0; DP.THRUST = 0; DP.WA = 0; DP.PWG = 1000;
baseline = struct('configuration', char(configuration), 'stage', 'design', ...
    'design', struct(), 'power', [], 'speed', [], 'altitude', [], ...
    'error', struct('identifier', '', 'message', ''));
try
    [DP, XD] = BALANCE_FUNCTION_DESIGN(DP, 0);
    baseline.design = struct('DP', DP, 'XD', XD, 'residual', DP.YD);
    OP = DP; X0 = 0;
    [OP, X0] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0);
    [baseline.power, OP, X0] = engine_baseline_scan(DP, OP, X0, n_power, 'power');
    OP = DP; X0 = 0;
    [OP, X0] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0);
    [baseline.speed, OP, X0] = engine_baseline_scan(DP, OP, X0, n_speed, 'speed');
    [baseline.altitude, OP, X0] = engine_baseline_scan(DP, OP, X0, n_altitude, 'altitude');
    baseline.stage = 'completed';
catch exception
    baseline.stage = 'failed';
    baseline.error.identifier = exception.identifier;
    baseline.error.message = exception.message;
end
end

function [records, OP, X0] = engine_baseline_scan(DP, OP, X0, count, stage)
records = struct('stage', stage, 'points', [], 'X', [], 'MSE', [], ...
    'THRUST', [], 'TIT', [], 'COMP_WP', [], 'TURB_WP', [], ...
    'MOTOR_WP', [], 'WA', [], 'NREF', [], 'R_COMP', [], 'R_TURB', [], ...
    'PWS', [], 'PWG', []);
records.X = cell(1, 0);
if strcmp(stage, 'power')
    values = linspace(1, .01, count);
    for k = 1:count
        OP.N_ref = -DP.N_ref; OP.PWG(1) = values(k) * DP.PWG(1);
        [OP, X0] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0);
        records = engine_append_baseline_record(records, OP, X0, k);
    end
elseif strcmp(stage, 'speed')
    step = DP.V_max / count;
    for k = 1:count
        OP.V = OP.V - step; OP.N_ref = -DP.N_ref; OP.PWG = DP.PWG;
        [OP, X0] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0);
        records = engine_append_baseline_record(records, OP, X0, k);
    end
else
    step = DP.H_max / count;
    for k = 1:count
        OP.H = OP.H - step; OP.N_ref = -DP.N_ref; OP.PWG = DP.PWG;
        [OP, X0] = BALANCE_FUNCTION_OFFDESIGN(DP, OP, X0);
        records = engine_append_baseline_record(records, OP, X0, k);
    end
end
end

function records = engine_append_baseline_record(records, OP, X0, k)
records.points(end+1) = k;
records.X{end+1} = OP.XO(OP.LM);
records.MSE(end+1) = OP.MSE;
records.THRUST(end+1) = OP.THRUST;
records.TIT(end+1) = OP.TO(1);
records.COMP_WP = [records.COMP_WP, OP.COMP_WP];
records.TURB_WP = [records.TURB_WP, OP.TURB_WP];
records.MOTOR_WP = [records.MOTOR_WP, OP.MOTOR_WP];
records.WA(end+1) = OP.WA;
records.NREF(:, end+1) = OP.NREF(:);
records.R_COMP(:, end+1) = OP.R_COMP(:);
records.R_TURB(:, end+1) = OP.R_TURB(:);
records.PWS(:, end+1) = OP.PWS(:);
records.PWG(:, end+1) = OP.PWG(:);
end

function engine_restore_baseline(old_directory, old_path)
cd(old_directory);
path(old_path);
end
