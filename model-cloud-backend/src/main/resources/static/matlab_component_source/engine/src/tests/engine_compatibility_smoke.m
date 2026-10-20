function report = engine_compatibility_smoke(reference_root)
%ENGINE_COMPATIBILITY_SMOKE Compare packaged design points with the demo.
% Run this from MATLAB with the untouched ENGINE+GENERATOR project path.
if nargin < 1
    error('engine:MissingReferenceRoot', 'reference_root is required.');
end
configurations = {'ducted fan', 'turboshaft', 'mixed turbofan'};
report = repmat(struct('configuration', '', 'design_flow_error', NaN, ...
    'design_residual_error', NaN, 'legacy_stage', ''), 1, numel(configurations));
for k = 1:numel(configurations)
    configuration = configurations{k};
    baseline = engine_legacy_baseline(reference_root, configuration, 2, 2, 2);
    model_dp = component_engine_initialize_configuration(configuration, 60, 0, 3000);
    model_dp = component_engine_apply_design_conditions(model_dp, 0, 0, 1000);
    [model_dp, ~] = component_engine_solve_design_point(model_dp);
    report(k).configuration = configuration;
    report(k).legacy_stage = baseline.stage;
    report(k).design_flow_error = abs(baseline.design.DP.WA - model_dp.WA);
    report(k).design_residual_error = abs(norm(baseline.design.residual, inf) - ...
        norm(model_dp.YD, inf));
    assert(report(k).design_flow_error <= 1e-8 + 1e-6 * abs(baseline.design.DP.WA));
    assert(report(k).design_residual_error <= 1e-8 + 1e-6 * ...
        abs(norm(baseline.design.residual, inf)));
end

baseline = engine_legacy_baseline(reference_root, 'turboshaft', 2, 2, 2);
model_dp = component_engine_initialize_configuration('turboshaft', 60, 0, 3000);
model_dp = component_engine_apply_design_conditions(model_dp, 0, 0, 1000);
[model_dp, ~] = component_engine_solve_design_point(model_dp);
[MISSION, THRUST_ARRAY, TIT_ARRAY, COMP_WP, TURB_WP, MOTOR_WP, OP, X0, DX] = ...
    component_run_engine_envelope(model_dp, 2, 2, 2);
assert(max(abs(baseline.power.THRUST - THRUST_ARRAY(1:2))) < 1e-8);
assert(max(abs(baseline.speed.THRUST - THRUST_ARRAY(3:4))) < 1e-8);
assert(max(abs(baseline.altitude.THRUST - THRUST_ARRAY(5:6))) < 1e-8);
assert(numel(TIT_ARRAY) == 6);
assert(isfield(MISSION, 'G'));
assert(~isfield(MISSION.G, 'ENVELOPE'));
assert(isequal(sort(fieldnames(MISSION.G)), ...
    sort({'DP', 'MAP', 'COMP_WP', 'TURB_WP', 'MOTOR_WP'}')));
assert(isstruct(OP) && isnumeric(X0) && isnumeric(DX));
end
