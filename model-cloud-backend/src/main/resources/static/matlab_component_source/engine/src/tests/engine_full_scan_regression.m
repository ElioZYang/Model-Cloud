function report = engine_full_scan_regression(reference_root)
%ENGINE_FULL_SCAN_REGRESSION Compare the default 20/100/100 mission arrays.
configurations = {'ducted fan', 'turboshaft'};
report = repmat(struct('configuration', '', 'points', 0, ...
    'thrust_error', NaN, 'tit_error', NaN, 'working_points_equal', false), ...
    1, numel(configurations));
for k = 1:numel(configurations)
    configuration = configurations{k};
    baseline = engine_legacy_baseline(reference_root, configuration, 20, 100, 100);
    assert(strcmp(baseline.stage, 'completed'), baseline.error.message);
    DP = component_engine_initialize_configuration(configuration, 60, 0, 3000);
    DP = component_engine_apply_design_conditions(DP, 0, 0, 1000);
    [DP, ~] = component_engine_solve_design_point(DP);
    [~, thrust, tit, comp, turb, motor] = component_run_engine_envelope(DP);
    expected_thrust = [baseline.power.THRUST, baseline.speed.THRUST, baseline.altitude.THRUST];
    expected_tit = [baseline.power.TIT, baseline.speed.TIT, baseline.altitude.TIT];
    expected_comp = [baseline.power.COMP_WP, baseline.speed.COMP_WP, baseline.altitude.COMP_WP];
    expected_turb = [baseline.power.TURB_WP, baseline.speed.TURB_WP, baseline.altitude.TURB_WP];
    expected_motor = [baseline.power.MOTOR_WP, baseline.speed.MOTOR_WP, baseline.altitude.MOTOR_WP];
    engine_assert_equal_numbers(thrust, expected_thrust);
    engine_assert_equal_numbers(tit, expected_tit);
    engine_assert_equal_numbers(comp, expected_comp);
    engine_assert_equal_numbers(turb, expected_turb);
    engine_assert_equal_numbers(motor, expected_motor);
    report(k).configuration = configuration;
    report(k).points = numel(thrust);
    report(k).thrust_error = engine_max_finite_error(thrust, expected_thrust);
    report(k).tit_error = engine_max_finite_error(tit, expected_tit);
    report(k).working_points_equal = true;
end
end

function engine_assert_equal_numbers(actual, expected)
assert(isequal(size(actual), size(expected)), 'Array shapes differ.');
assert(isequal(isfinite(actual), isfinite(expected)), 'Nonfinite positions differ.');
assert(isequal(isnan(actual), isnan(expected)), 'NaN positions differ.');
assert(isequal(isinf(actual), isinf(expected)), 'Inf positions differ.');
finite = isfinite(expected);
assert(all(abs(actual(finite) - expected(finite)) <= ...
    1e-8 + 1e-6 * abs(expected(finite))), 'Finite values differ.');
end

function maximum = engine_max_finite_error(actual, expected)
finite = isfinite(expected);
if any(finite, 'all')
    maximum = max(abs(actual(finite) - expected(finite)));
else
    maximum = 0;
end
end
