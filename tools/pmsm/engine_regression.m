function report=engine_regression(repo,reference,full_scan)
% Compare the compiled HPCGV assembly and callback with the original engine.
if nargin<3, full_scan=false; end
oldpath=path; oldpwd=pwd;
cleanup=onCleanup(@() restore(oldpath,oldpwd)); %#ok<NASGU>
addpath(genpath(reference)); cd(reference);
original=struct('V',60,'M',0,'H',3000,'V_max',60,'H_max',3000,'type',"hpcgv turboshaft");
original=INPUT_DESIGN_PARAMETERS(original); original.THRUST=0; original.WA=0; original.PWG=1000; original.display=0;
[original,xd]=BALANCE_FUNCTION_DESIGN(original,0);
[original_op,x0,~]=BALANCE_FUNCTION_OFFDESIGN(original,original,0);
path(oldpath); cd(oldpwd);
component_root=fullfile(repo,'model-cloud-backend/src/main/resources/static/matlab_component_source');
addpath(genpath(component_root));
graph=jsondecode(fileread(fullfile(repo,'contracts/matlab/fixtures/engine/engine.configuration.hpcgv-turboshaft.trusted-graph.json')));
mc_pmsm_program_registry('clear','');
registry=@mc_pmsm_program_registry;
registry_cleanup=onCleanup(@() registry('clear','')); %#ok<NASGU>
mc_pmsm_program_registry('install',graph.modelPrograms);
nodes=records(graph.nodes);
index=find(strcmp(string({nodes.componentId}),'engine.stage.initialize-configuration'));
assembly=nodes(index).values.assembly_json;
dp=component_engine_initialize_configuration(assembly,60,0,3000);
assert(isequal(dp.F,original.F)&&isequal(dp.SHAFT,original.SHAFT)&&isequal(dp.EXT,original.EXT));
assert(dp.SHAFT_CONTROL==1&&dp.NM1==1);
dp=component_engine_apply_design_conditions(dp,0,0,1000);
[dp,actual_xd]=component_engine_solve_design_point(dp);
compare(xd,actual_xd,'design unknowns');
for name=["WA","PWG","PWS","PWH","TPR","WCOR","GAS_PROPERTY","YD"]
    compare(original.(name),dp.(name),name);
end
[op,actual_x0,~,diagnostics]=BALANCE_FUNCTION_OFFDESIGN(dp,dp,0);
compare(x0,actual_x0,'offdesign unknowns');
for name=["WA","PWG","PWS","PWH","TPR","GAS_PROPERTY","MOTOR_WP"]
    if isfield(original_op,name)&&isfield(op,name), compare(original_op.(name),op.(name),name); end
end
report=struct('passed',true,'designResidual',norm(dp.YD,inf),...
    'offdesignResidual',diagnostics.residual_norm,'offdesignExitflag',diagnostics.exitflag);
edited_file=fullfile(repo,'model-cloud-backend/target/pmsm/hpcgv-rewired.trusted-graph.json');
if isfile(edited_file)
    edited=jsondecode(fileread(edited_file));
    mc_pmsm_program_registry('clear',''); mc_pmsm_program_registry('install',edited.modelPrograms);
    trial=component_engine_initialize_configuration(assembly,60,0,3000);
    trial=component_engine_apply_design_conditions(trial,0,0,1000);
    trial=component_engine_solve_design_point(trial);
    report.rewiredAirflowDifference=trial.WA-dp.WA;
    assert(abs(report.rewiredAirflowDifference)>1e-8,'Internal rewiring must affect the engine solution.');
    assert(trial.pmsm_parameters.input.cooling==1);
    mc_pmsm_program_registry('clear',''); mc_pmsm_program_registry('install',graph.modelPrograms);
end
if full_scan
    [mission,~,~,~,~,motor_wp,op]=component_run_engine_envelope(dp,20,100,100);
    assert(isequal(size(motor_wp),[2,220])&&all(isfinite(motor_wp),'all'));
    report.scanPoints=size(motor_wp,2); report.finalMotorWorkpoint=op.MOTOR_WP;
    output=fullfile(repo,'tools/pmsm/verification'); if ~isfolder(output), mkdir(output); end
    design_plot=component_engine_plot_flow(dp,fullfile(output,'design'),'design');
    final_plot=component_engine_plot_map_mission(mission,fullfile(output,'final'),'final');
    scan=component_engine_envelope_initialize(dp);
    [~,power_mission]=component_engine_envelope_power(scan,20);
    power_plot=component_engine_plot_map_mission(power_mission,fullfile(output,'power'),'power');
    report.plotFiles=numel(design_plot.files)+numel(power_plot.files)+numel(final_plot.files);
end
disp(report);
end
function result=records(value)
if iscell(value)
    names={}; for k=1:numel(value), names=union(names,fieldnames(value{k})); end
    for k=1:numel(value)
        for field=names(:)', if ~isfield(value{k},field{1}), value{k}.(field{1})=[]; end; end
        value{k}=orderfields(value{k},names);
    end
    value=[value{:}];
end
result=reshape(value,1,[]);
end
function compare(expected,actual,name)
assert(isequal(size(expected),size(actual)),"Shape: "+name);
assert(isreal(actual)&&all(isfinite(actual),'all'),"Nonfinite: "+name);
assert(all(abs(expected-actual)<=1e-8+1e-6*abs(expected),'all'),"Difference: "+name);
end
function restore(oldpath,oldpwd)
path(oldpath); cd(oldpwd);
end
