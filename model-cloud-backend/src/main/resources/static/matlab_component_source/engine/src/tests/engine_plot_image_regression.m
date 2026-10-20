function report = engine_plot_image_regression(reference_root)
%ENGINE_PLOT_IMAGE_REGRESSION Compare wrapper PNGs with original plot calls.
old_directory = pwd;
old_path = path;
old_visible = get(groot, 'DefaultFigureVisible');
directories = arrayfun(@(~) tempname(tempdir), 1:6, 'UniformOutput', false);
cleanup = onCleanup(@() engine_plot_test_restore(old_directory, old_path, ...
    old_visible, directories)); %#ok<NASGU>
for k = 1:numel(directories), mkdir(directories{k}); end

DP = component_engine_initialize_configuration('turboshaft', 60, 0, 3000);
DP = component_engine_apply_design_conditions(DP, 0, 0, 1000);
[DP, ~] = component_engine_solve_design_point(DP);
state = component_engine_envelope_initialize(DP);
[state, power_mission] = component_engine_envelope_power(state, 3);
state = component_engine_envelope_speed_initialize(state);
state = component_engine_envelope_speed(state, 4);
state = component_engine_envelope_altitude(state, 4);
final_mission = component_engine_envelope_finalize(state);

component_engine_plot_flow(DP, directories{1}, 'design');
component_engine_plot_map_mission(power_mission, directories{2}, 'power');
component_engine_plot_map_mission(final_mission, directories{3}, 'final');

cd(reference_root);
ADD_PATH_ENGINE;
set(groot, 'DefaultFigureVisible', 'off');
cd(directories{4}); PLOTFLOW(DP); close all;
cd(directories{5}); DRAW_MAP_MISSION(power_mission); close all;
cd(directories{6}); DRAW_MAP_MISSION(final_mission); close all;

phases = {'design', 'power', 'final'};
report = repmat(struct('phase', '', 'files', 0, 'pixel_equal', false, ...
    'different_channels', 0, 'total_channels', 0, ...
    'max_channel_difference', 0), 1, 3);
for k = 1:3
    wrapped = dir(fullfile(directories{k}, '*.png'));
    original = dir(fullfile(directories{k + 3}, '*.png'));
    wrapped_names = sort(string({wrapped.name}));
    original_names = sort(string({original.name}));
    assert(isequal(wrapped_names, original_names), 'Plot file names differ.');
    different_channels = 0;
    total_channels = 0;
    max_difference = 0;
    for n = 1:numel(wrapped_names)
        actual = imread(fullfile(directories{k}, wrapped_names(n)));
        expected = imread(fullfile(directories{k + 3}, original_names(n)));
        assert(isequal(size(actual), size(expected)), 'PNG dimensions differ.');
        difference = abs(double(actual) - double(expected));
        different_channels = different_channels + nnz(difference);
        total_channels = total_channels + numel(difference);
        max_difference = max(max_difference, max(difference, [], 'all'));
    end
    report(k).phase = phases{k};
    report(k).files = numel(wrapped_names);
    report(k).pixel_equal = different_channels == 0;
    report(k).different_channels = different_channels;
    report(k).total_channels = total_channels;
    report(k).max_channel_difference = max_difference;
    % MATLAB's exportgraphics may vary a few anti-aliased text pixels
    % between separate figure renderings. Guard against visible changes.
    assert(different_channels <= 1e-3 * total_channels && ...
        max_difference <= 10, 'PNG content differs beyond raster tolerance.');
end
end

function engine_plot_test_restore(old_directory, old_path, old_visible, directories)
close all;
set(groot, 'DefaultFigureVisible', old_visible);
cd(old_directory);
path(old_path);
for k = 1:numel(directories)
    if exist(directories{k}, 'dir'), rmdir(directories{k}, 's'); end
end
end
