function result = component_engine_plot_map_mission(MISSION, output_directory, phase)
%COMPONENT_ENGINE_PLOT_MAP_MISSION Call original DRAW_MAP_MISSION.
if nargin < 2 || isempty(output_directory)
    output_directory = tempname(tempdir);
    phase = 'final';
elseif nargin < 3 || isempty(phase)
    % The catalog exposes phase, while the filesystem location is private
    % task runtime state. Julia starts MATLAB in the task directory.
    phase = char(string(output_directory));
    engine_plot_validate_phase(phase);
    output_directory = fullfile(pwd, phase);
end
output_directory = char(string(output_directory));
phase = char(string(phase));
old_directory = pwd;
old_path = path;
old_defaults = engine_plot_defaults();
old_figures = findall(0, 'Type', 'figure');
engine_plot_prepare_directory(output_directory);
old_files = engine_plot_files(output_directory);
cleanup = onCleanup(@() engine_plot_restore(old_directory, old_path, ...
    old_defaults, old_figures)); %#ok<NASGU>
set(groot, 'DefaultFigureVisible', 'off');
runtime_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(runtime_root), '-begin');
cd(output_directory);
DRAW_MAP_MISSION(MISSION);
new_files = engine_plot_file_difference(old_files, engine_plot_files(output_directory));
result = struct('function', "DRAW_MAP_MISSION", 'phase', string(phase), ...
    'output_directory', string(output_directory), ...
    'files', engine_plot_manifest(new_files, phase, output_directory, ...
    'DRAW_MAP_MISSION'));
end

function defaults = engine_plot_defaults()
properties = {'DefaultAxesFontName', 'DefaultAxesFontSize', ...
    'DefaultTextFontName', 'DefaultTextFontSize', ...
    'DefaultLegendFontName', 'DefaultLegendFontSize', ...
    'DefaultLineLineWidth', 'DefaultFigureVisible'};
defaults = cell(1, numel(properties));
for k = 1:numel(properties), defaults{k} = get(groot, properties{k}); end
end

function engine_plot_prepare_directory(output_directory)
if ~isfolder(output_directory)
    [ok, message] = mkdir(output_directory);
    if ~ok, error('engine:PlotOutputDirectory', '%s', message); end
end
if ~isfolder(output_directory)
    error('engine:PlotOutputDirectory', ...
        'Plot output directory was not created: %s', output_directory);
end
end

function engine_plot_validate_phase(phase)
if isempty(regexp(phase, '^[A-Za-z0-9_-]+$', 'once')) %#ok<RGXP1>
    error('engine:InvalidPlotPhase', 'Invalid plot phase: %s', phase);
end
end

function names = engine_plot_files(output_directory)
files = dir(fullfile(output_directory, '*.png'));
names = string({files.name});
end

function files = engine_plot_file_difference(old_files, new_files)
files = setdiff(new_files, old_files, 'stable');
end

function manifest = engine_plot_manifest(names, phase, output_directory, source)
manifest = repmat(struct('id', "", 'phase', string(phase), ...
    'fileName', "", 'source', string(source), 'path', ""), 1, numel(names));
for k = 1:numel(names)
    manifest(k).id = string(phase) + ":" + names(k);
    manifest(k).phase = string(phase);
    manifest(k).fileName = names(k);
    manifest(k).source = string(source);
    manifest(k).path = string(fullfile(output_directory, names(k)));
end
if isempty(manifest)
    manifest = struct('id', string.empty(1,0), 'phase', string.empty(1,0), ...
        'fileName', string.empty(1,0), 'source', string.empty(1,0), ...
        'path', string.empty(1,0));
end
end

function engine_plot_restore(old_directory, old_path, old_defaults, old_figures)
new_figures = setdiff(findall(0, 'Type', 'figure'), old_figures);
if ~isempty(new_figures), close(new_figures); end
properties = {'DefaultAxesFontName', 'DefaultAxesFontSize', ...
    'DefaultTextFontName', 'DefaultTextFontSize', ...
    'DefaultLegendFontName', 'DefaultLegendFontSize', ...
    'DefaultLineLineWidth', 'DefaultFigureVisible'};
for k = 1:numel(properties), set(groot, properties{k}, old_defaults{k}); end
cd(old_directory);
path(old_path);
end
