function report=standalone_regression(standalone)
oldpath=path; cleanup=onCleanup(@() path(oldpath)); %#ok<NASGU>
addpath(genpath(fullfile(standalone,'shared')));
request=struct('mode','design','power_kw',50,'speed_rpm',60000,...
    'flow',struct('T',288.15,'P',101325,'WA',1,'FAR',0,'D',0,'EFFH',1));
design=mc_pmsm_run(request);
assert(isfinite(design.PWS));
request.mode='offdesign'; request.design_model=design.pmsm_params;
request.power_kw=25; request.speed_rpm=48000;
off=mc_pmsm_run(request); assert(isfinite(off.PWS));
request.mode='thermal'; request.design_model=off.pmsm_params;
fixed=mc_pmsm_run(request);
request.free_temperature_mask=[true;true];
steady=mc_pmsm_run(request);
assert(steady.solver.exitflag>0&&steady.solver.normalizedResidual<=1e-6);
assert(all(isfinite(fixed.pmsm_params.thermal.temp_balance)));
programs=jsondecode(fileread(fullfile(standalone,'shared/default-program.json')));
input=design; input.pmsm_input=design.pmsm_params.input; input.PWG=50; input.NM=60000;
first=mc_pmsm_execute_program(programs.design,input);
input.pmsm_input.B_g=input.pmsm_input.B_g*.95;
changed=mc_pmsm_execute_program(programs.design,input);
assert(abs(first.PWS-changed.PWS)>1e-8);
report=struct('passed',true,'designPower',design.PWG,'offdesignPower',off.PWG,...
    'steadyResidual',steady.solver.normalizedResidual,'editedDifference',changed.PWS-first.PWS);
mc_pmsm_program_registry('clear','');
registry= @mc_pmsm_program_registry;
cleanupRegistry=onCleanup(@() registry('clear','')); %#ok<NASGU>
mc_pmsm_program_registry('install',struct('id','test_motor','entries',programs));
for power=[50,45,40]
    input.PWG=power;
    direct=mc_pmsm_execute_program(programs.design,input);
    registered=mc_pmsm_invoke(input,'test_motor');
    assert(abs(direct.PWS-registered.PWS)<1e-10);
end
% Interleave different instances, then repeat the first input without stale state.
mc_pmsm_program_registry('install',struct('id','second_motor','entries',programs));
input.PWG=50; input.mode='design';
before=mc_pmsm_invoke(input,'test_motor');
other=input; other.PWG=25; other.NM=48000;
mc_pmsm_invoke(other,'second_motor');
after=mc_pmsm_invoke(input,'test_motor');
assert(isequaln(before,after),'PMSM instances must not share operating state.');
% Invalid operating points must fail, and failures must identify the inner node.
bad=input; bad.PWG=0;
expect_failure(@() mc_pmsm_invoke(bad,'test_motor'),'PMSM:ProgramNodeFailed','design_prepare');
detail=mc_pmsm_program_registry('error','');
assert(strcmp(detail.entrypoint,'design')&&strcmp(detail.programId,'test_motor'));
assert(strcmp(detail.exceptionIdentifier,'PMSM:InvalidPower')&&~isempty(detail.originPath));
mc_pmsm_invoke(input,'test_motor');
assert(isempty(fieldnames(mc_pmsm_program_registry('error',''))),'Successful calls must clear stale errors.');
bad.mode='offdesign'; bad.PWG_ref=1; bad.N_ref=1; bad.pmsm_input=design.pmsm_params;
expect_failure(@() mc_pmsm_invoke(bad,'test_motor'),'PMSM:ProgramNodeFailed','off_operating');
detail=mc_pmsm_program_registry('error',''); assert(strcmp(detail.entrypoint,'offdesign'));
bad=struct('mode','thermal','pmsm_params',struct());
expect_failure(@() mc_pmsm_invoke(bad,'test_motor'),'PMSM:ProgramNodeFailed','request');
detail=mc_pmsm_program_registry('error',''); assert(strcmp(detail.entrypoint,'thermal'));
invalid=request; invalid.flow.WA=0;
expect_failure(@() mc_pmsm_run(invalid),'PMSM:InvalidFlow','');
mc_pmsm_program_registry('clear','');
expect_failure(@() mc_pmsm_invoke(input,'test_motor'),'PMSM:UnknownProgram','');
report.repeatedCalls=3; report.isolatedInstances=2; report.rejectedInvalidCases=5;
disp(report);
end
function expect_failure(operation,identifier,location)
try
    operation();
catch failure
    assert(strcmp(failure.identifier,identifier),failure.getReport());
    assert(isempty(location)||contains(failure.message,location),failure.message);
    return;
end
error('PMSM:RegressionExpectedFailure','Expected failure: %s',identifier);
end
