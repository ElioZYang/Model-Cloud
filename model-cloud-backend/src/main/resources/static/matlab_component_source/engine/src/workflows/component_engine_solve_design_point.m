function [DP, XD] = component_engine_solve_design_point(DP)
%COMPONENT_ENGINE_SOLVE_DESIGN_POINT Preserve the legacy design solve.
runtime_root = fileparts(fileparts(mfilename('fullpath')));
old_directory = pwd;
old_path = path;
cleanup = onCleanup(@() engine_restore_environment(old_directory, old_path)); %#ok<NASGU>
cd(runtime_root);
addpath(genpath(runtime_root), '-begin');
initial=DP;
[DP, XD, diagnostics] = BALANCE_FUNCTION_DESIGN(DP, 0);
if DP.NM1>0
    DP.pmsmSolverDiagnostics=component_engine_pmsm_diagnostics(initial,DP,diagnostics,'design');
end
end

function engine_restore_environment(old_directory, old_path)
cd(old_directory);
path(old_path);
end
