function report=pmsm_reference_regression(reference,standalone)
% Compare shared component stages with the untouched original equations.
oldpath=path; oldpwd=pwd; cleanup=onCleanup(@() restore(oldpath,oldpwd)); %#ok<NASGU>
addpath(genpath(reference)); cd(fullfile(reference,'Input'));
config=INPUT_ELECTRIC;
cases=[50,60000,1;50,60000,2;50,60000,3;1000,10000,2;-50,60000,2];
reference_results=cell(size(cases,1),3);
for k=1:size(cases,1)
    config.cooling=cases(k,3);
    design=PMSM_design(config,cases(k,1),cases(k,2));
    off=PMSM_off_design(design,.5*cases(k,1),.8*cases(k,2));
    input=struct('pmsm_params',design,'mode',"design",'T',288.15,'P',101325,...
        'FAR',0,'D',0,'WA',1,'EFFH',1);
    reference_results(k,:)={design,off,PMSM_thermal_network(input)};
end
path(oldpath); cd(oldpwd); addpath(genpath(fullfile(standalone,'shared')));
shared_config=mc_pmsm_read_configuration;
for k=1:size(cases,1)
    shared_config.cooling=cases(k,3);
    design=mc_pmsm_PMSM_design(shared_config,cases(k,1),cases(k,2));
    off=mc_pmsm_PMSM_off_design(design,.5*cases(k,1),.8*cases(k,2));
    input=struct('pmsm_params',design,'mode',"design",'T',288.15,'P',101325,...
        'FAR',0,'D',0,'WA',1,'EFFH',1);
    actual={design,off,mc_pmsm_PMSM_thermal_network(input)};
    for j=1:3, compare(reference_results{k,j},actual{j},sprintf('case%d.mode%d',k,j)); end
end
report=struct('cases',cases,'passed',true,'absoluteTolerance',1e-8,'relativeTolerance',1e-6);
disp(report);
end

function compare(expected,actual,location)
if isnumeric(expected)
    assert(isequal(size(expected),size(actual)),['shape: ',location]);
    assert(isequal(isfinite(expected),isfinite(actual)),['finite: ',location]);
    finite=isfinite(expected);
    assert(all(abs(expected(finite)-actual(finite))<=1e-8+1e-6*abs(expected(finite)),'all'),location);
elseif isstruct(expected)
    assert(isequal(fieldnames(expected),fieldnames(actual)),['fields: ',location]);
    for name=string(fieldnames(expected))', compare(expected.(name),actual.(name),location+"."+name); end
elseif istable(expected)
    assert(isequaln(expected,actual),location);
else
    assert(isequaln(expected,actual),location);
end
end

function restore(oldpath,oldpwd)
path(oldpath); cd(oldpwd);
end
