function report=engine_full_reference_regression(repo,reference)
% Compare all 20/100/100 scan outputs with the untouched TURBOSHAFT_MAIN path.
oldpath=path; oldpwd=pwd;
cleanup=onCleanup(@() restore(oldpath,oldpwd)); %#ok<NASGU>
result_file=fullfile(repo,'tools/pmsm/verification/hpcgv-validated/result.json');
assert(isfile(result_file),'Run the validated Julia graph first.');
actual=jsondecode(fileread(result_file)); assert(actual.success);
addpath(genpath(reference)); cd(reference);
DP=struct('V',60,'M',0,'H',3000,'V_max',60,'H_max',3000,'type',"hpcgv turboshaft");
DP=INPUT_DESIGN_PARAMETERS(DP); DP.THRUST=0; DP.WA=0; DP.PWG=1000; DP.display=0;
DP=BALANCE_FUNCTION_DESIGN(DP,0);
arrays=struct('THRUST_ARRAY',[],'TIT_ARRAY',[],'COMP_WP',[],'TURB_WP',[],'MOTOR_WP',[]);
OP=DP; X0=0; DX=0;
[OP,X0,~]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0);
powers=linspace(1,.01,20);
for k=1:20
    OP.N_ref=-DP.N_ref; OP.PWG(1)=powers(k)*DP.PWG(1);
    [OP,X0,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0+0.0*DX);
    arrays=append(arrays,OP);
end
OP=DP; X0=0;
[OP,X0,~]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0);
for k=1:100
    OP.V=OP.V-DP.V_max/100; OP.N_ref=-DP.N_ref; OP.PWG=DP.PWG;
    [OP,X0,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0+0.0*DX);
    arrays=append(arrays,OP);
end
for k=1:100
    OP.H=OP.H-DP.H_max/100; OP.N_ref=-DP.N_ref; OP.PWG=DP.PWG;
    [OP,X0,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0+0.0*DX);
    arrays=append(arrays,OP);
end
outputs=actual.nodeResults.root__scan__scan_finalize.outputs;
maximum=0;
for name=string(fieldnames(arrays))'
    maximum=max(maximum,compare(arrays.(name),outputs.(name),name));
end
for name=["WA","PWG","PWS","PWH","TPR","GAS_PROPERTY","MOTOR_WP","YO"]
    maximum=max(maximum,compare(OP.(name),outputs.OP.(name),"final OP."+name));
end
diagnostics=outputs.MISSION_final.G.pmsmSolverDiagnostics;
assert(numel(diagnostics)==220&&all([diagnostics.converged]));
assert(all([diagnostics.exitflag]>0));
assert(max([diagnostics.normalized_residual])<=1e-6);
report=struct('passed',true,'points',[20,100,100],'comparedArrays',{fieldnames(arrays)},...
    'maxAbsoluteDifference',maximum,'maxNormalizedResidual',max([diagnostics.normalized_residual]));
folder=fullfile(repo,'tools/pmsm/verification');
save(fullfile(folder,'hpcgv-original-reference.mat'),'DP','OP','arrays','X0','DX');
file=fopen(fullfile(folder,'hpcgv-full-reference.json'),'w');
file_cleanup=onCleanup(@() fclose(file)); %#ok<NASGU>
fprintf(file,'%s',jsonencode(report));
disp(report);
end
function arrays=append(arrays,OP)
arrays.THRUST_ARRAY=[arrays.THRUST_ARRAY,OP.THRUST];
arrays.TIT_ARRAY=[arrays.TIT_ARRAY,OP.TO(1)];
for name=["COMP_WP","TURB_WP","MOTOR_WP"]
    arrays.(name)=[arrays.(name),OP.(name)];
end
end
function difference=compare(expected,actual,name)
% JSON cannot preserve row-vector orientation; matrix dimensions remain exact.
if isvector(expected)&&isvector(actual), actual=reshape(actual,size(expected)); end
assert(isequal(size(expected),size(actual)),"Shape: "+name);
assert(isreal(actual)&&all(isfinite(actual),'all'),"Nonfinite: "+name);
delta=abs(expected-actual);
assert(all(delta<=1e-8+1e-6*abs(expected),'all'),"Difference: "+name);
if isempty(delta), difference=0; else, difference=max(delta,[],'all'); end
end
function restore(oldpath,oldpwd)
path(oldpath); cd(oldpwd);
end
