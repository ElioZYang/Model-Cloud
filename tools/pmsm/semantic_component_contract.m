function report=semantic_component_contract(repo,standalone)
old=path; cleanup=onCleanup(@() path(old)); %#ok<NASGU>
addpath(fullfile(standalone,'shared/core'));
catalog=jsondecode(fileread(fullfile(repo,'model-cloud-backend/src/main/resources/matlab-components/pmsm-components.json')));
if ~iscell(catalog), catalog=num2cell(catalog); end
count=0;
for k=1:numel(catalog)
    item=catalog{k};
    if ~startsWith(item.id,'pmsm.c.'), continue; end
    assert(nargin(item.functionName)==numel(item.invocation.arguments),item.id);
    assert(nargout(item.functionName)>=max([item.invocation.returns.returnIndex])+1,item.id);
    ports=item.inputs; if ~iscell(ports), ports=num2cell(ports); end
    assert(~any(cellfun(@(p) strcmp(p.type,'pmsm.state'),ports)),item.id);
    count=count+1;
end
c=mc_pmsm_read_configuration;
input=struct('mode','design','pmsm_input',c,'PWG',50,'NM',60000,...
    'T',288.15,'P',101325,'WA',1,'FAR',0,'D',0,'EFFH',1);
request=mc_pmsm_c_request(input);
assert(request.power_kw==50&&request.speed_rpm==60000&&isequal(request.configuration,c));
model=mc_pmsm_PMSM_design(c,50,60000);
raw=input; raw.pmsm_params=model;
thermal=mc_pmsm_PMSM_thermal_network(raw);
outlet=struct('T',thermal.T,'P',thermal.P,'TPR',thermal.TPR,'WCOR',thermal.WCOR);
actual=mc_pmsm_c_output(input,thermal.pmsm_params,outlet);
assert(abs(actual.PWS-model.performance.mechanical_power/1000)<1e-12);
assert(isequal(mc_pmsm_program_input(input),input));
report=struct('passed',true,'components',count,'adaptersPassed',true); disp(report);
end
