function report=engine_existing_regression(repo)
oldpath=path; cleanup=onCleanup(@() path(oldpath)); %#ok<NASGU>
addpath(genpath(fullfile(repo,'model-cloud-backend/src/main/resources/static/matlab_component_source')));
folder=fullfile(repo,'contracts/matlab/fixtures/engine');
files=dir(fullfile(folder,'*.trusted-graph.json'));
report=struct('configuration',{},'passed',{},'scanStatus',{},'designResidual',{});
output=fullfile(repo,'tools/pmsm/verification'); if ~isfolder(output), mkdir(output); end
checkpoint=fullfile(output,'existing-engines.json');
if isfile(checkpoint), report=reshape(jsondecode(fileread(checkpoint)),1,[]); end
for file=files'
    if contains(file.name,'hpcgv'), continue; end
    if ~isempty(report)&&any(strcmp(string({report.configuration}),string(file.name))), continue; end
    graph=jsondecode(fileread(fullfile(file.folder,file.name))); nodes=records(graph.nodes);
    index=find(strcmp(string({nodes.componentId}),'engine.stage.initialize-configuration'));
    init=nodes(index).values;
    assembly=jsondecode(init.assembly_json);
    preset=component_engine_initialize_configuration(assembly.assemblyDefaults.type,init.V,init.M,init.H);
    scene=component_engine_initialize_configuration(init.assembly_json,init.V,init.M,init.H);
    for field=["F","SHAFT","EXT","PRC","EFFC","EFFT","TO","E_mech","E_motor"]
        assert(isequaln(preset.(field),scene.(field)),file.name+" initialization "+field);
    end
    index=find(strcmp(string({nodes.componentId}),'engine.stage.apply-design-conditions'));
    conditions=nodes(index).values;
    preset=component_engine_apply_design_conditions(preset,conditions.thrust,conditions.air_mass_flow,conditions.generator_power_kw);
    scene=component_engine_apply_design_conditions(scene,conditions.thrust,conditions.air_mass_flow,conditions.generator_power_kw);
    design_a=capture_design(preset); design_b=capture_design(scene);
    if ~design_a.completed||~design_b.completed
        assert(~design_a.completed&&~design_b.completed&&strcmp(design_a.error,design_b.error),file.name+" design failure parity");
        status=['same_native_design_exception:',design_a.error];
        report(end+1)=struct('configuration',file.name,'passed',true,'scanStatus',status,'designResidual',NaN); %#ok<AGROW>
        persist(checkpoint,report); fprintf('%s: %s\n',file.name,status); continue;
    end
    a=design_a.dp; xa=design_a.x; b=design_b.dp; xb=design_b.x;
    compare(xa,xb,file.name+" design unknowns"); compare(a.YD,b.YD,file.name+" design residuals");
    left=capture(a); right=capture(b);
    assert(left.completed==right.completed,file.name+" scan status");
    if left.completed
        compare(left.thrust,right.thrust,file.name+" thrust");
        compare(left.tit,right.tit,file.name+" TIT");
        compare(left.motor,right.motor,file.name+" motor");
        status='completed';
    else
        assert(strcmp(left.error,right.error),file.name+" native error");
        status=['same_native_exception:',left.error];
    end
    report(end+1)=struct('configuration',file.name,'passed',true,'scanStatus',status,'designResidual',norm(b.YD,inf)); %#ok<AGROW>
    persist(checkpoint,report);
    fprintf('%s: %s\n',file.name,status);
end
assert(numel(report)==11);
persist(checkpoint,report);
end
function result=capture_design(dp)
try
    [dp,x]=component_engine_solve_design_point(dp);
    result=struct('completed',true,'dp',dp,'x',x);
catch exception
    result=struct('completed',false,'error',exception.identifier);
end
end
function persist(file,report)
handle=fopen(file,'w'); fwrite(handle,jsonencode(report),'char'); fclose(handle);
end
function result=capture(dp)
try
    [~,thrust,tit,~,~,motor]=component_run_engine_envelope(dp,3,4,4);
    result=struct('completed',true,'thrust',thrust,'tit',tit,'motor',motor);
catch exception
    result=struct('completed',false,'error',exception.identifier);
end
end
function value=records(value)
if iscell(value)
    names={}; for k=1:numel(value), names=union(names,fieldnames(value{k})); end
    for k=1:numel(value)
        for field=names(:)', if ~isfield(value{k},field{1}), value{k}.(field{1})=[]; end; end
        value{k}=orderfields(value{k},names);
    end
    value=[value{:}];
end
value=reshape(value,1,[]);
end
function compare(expected,actual,name)
assert(isequal(size(expected),size(actual)),"Shape: "+name);
assert(isequal(isfinite(expected),isfinite(actual)),"Finite pattern: "+name);
finite=isfinite(expected);
assert(all(abs(expected(finite)-actual(finite))<=1e-8+1e-6*abs(expected(finite)),'all'),"Difference: "+name);
end
