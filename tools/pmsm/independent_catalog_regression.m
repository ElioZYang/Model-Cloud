function report=independent_catalog_regression(repo)
% Verify restored formulas and default resources under the runner's shared path.
oldpath=path;
cleanup=onCleanup(@() path(oldpath)); %#ok<NASGU>
root=fullfile(repo,'model-cloud-backend/src/main/resources/static/matlab_component_source');
addpath(genpath(root));
original=fullfile(root,'PMSM/src');
addpath(fullfile(original,'components'),fullfile(original,'module'),fullfile(original,'io'),'-begin');
independent=fullfile(root,'PMSM_Independent');
workbook=fullfile(independent,'input/pmsm input.xlsx');
referenceConfig=INPUT_ELECTRIC(workbook);
configuration=mc_pmsm_ind_INPUT_ELECTRIC();
assert(isequaln(referenceConfig,configuration),'Standalone default workbook changed.');
catalog=jsondecode(fileread(fullfile(repo,'model-cloud-backend/src/main/resources/matlab-components/pmsm-independent-components.json')));
for k=1:numel(catalog)
    if iscell(catalog), item=catalog{k}; else, item=catalog(k); end
    assert(startsWith(which(item.functionName),independent),'Standalone function resolved outside its library.');
end
expected=PMSM_design(referenceConfig,50,60000);
actual=mc_pmsm_ind_PMSM_design(configuration,50,60000);
assert(isequaln(expected,actual),'Restored design differs from original.');
assert(isequaln(PMSM_off_design(expected,25,40000),mc_pmsm_ind_PMSM_off_design(actual,25,40000)),...
    'Restored offdesign differs from original.');
for cooling=1:3
    model=actual; model.input.cooling=cooling;
    flow=struct('T',300,'P',101325,'WA',0.1,'D',0,'EFFH',1,'FAR',0,'mode',"design",'pmsm_params',model);
    assert(isequaln(PMSM_thermal_network(flow),mc_pmsm_ind_PMSM_thermal_network(flow)),...
        'Restored thermal network differs from original.');
end
request=struct('parameters',struct('electric_power_kW',50,'rated_speed_rpm',60000));
configured=mc_pmsm_ind_component_motor_configuration(request);
draft=mc_pmsm_ind_component_dimensions_electromagnetic(struct('inputs',configured.outputs));
mass=mc_pmsm_ind_component_mass_cooling(struct('inputs',draft.outputs));
result=mc_pmsm_ind_component_losses_performance(struct('inputs',mass.outputs));
motor=mc_pmsm_ind_component_create_motor_model(struct('inputs',result.outputs));
assert(isequaln(result.outputs.performance,actual.performance),'Restored component chain differs.');
assert(isfield(motor.outputs,'motor_model'));
hybrid=mc_pmsm_read_configuration('');
assert(any(strcmp(hybrid.material.data.Properties.VariableNames,'thermal_conductivity (W/(m·K))')));
assert(any(strcmp(configuration.material.data.Properties.VariableNames,'thermal_conductivity (W/(mK))')));
report=struct('passed',true,'components',numel(catalog),'design',true,'offdesign',true,...
    'coolingNetworks',3,'componentChain',true,'isolatedDefaults',true);
file=fopen(fullfile(repo,'tools/pmsm/verification/independent-catalog.json'),'w');
fileCleanup=onCleanup(@() fclose(file)); %#ok<NASGU>
fprintf(file,'%s',jsonencode(report));
disp(report);
end
