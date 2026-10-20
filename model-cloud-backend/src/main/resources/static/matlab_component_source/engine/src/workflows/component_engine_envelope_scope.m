function cleanup = component_engine_envelope_scope()
%COMPONENT_ENGINE_ENVELOPE_SCOPE Isolate the engine runtime for one stage.
runtime_root = fileparts(fileparts(mfilename('fullpath')));
old_directory = pwd;
old_path = path;
cd(runtime_root);
addpath(genpath(runtime_root), '-begin');
cleanup = onCleanup(@() component_engine_envelope_restore(old_directory, old_path));
end

function component_engine_envelope_restore(old_directory, old_path)
cd(old_directory);
path(old_path);
end
