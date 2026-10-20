function INPUT=mc_pmsm_configuration(request)
parameters=request.parameters;
file='';
if isfield(request,'resources')&&isfield(request.resources,'motor_config_file')
    file=request.resources.motor_config_file;
end
config=mc_pmsm_read_configuration(file);
INPUT=struct('mode',"design",'pmsm_input',config,'PWG',parameters.power_kw,...
    'NM',parameters.speed_rpm,'T',parameters.T,'P',parameters.P,...
    'WA',parameters.WA,'FAR',parameters.FAR,'D',parameters.D,'EFFH',parameters.EFFH);
mc_pmsm_validate_operating(INPUT.PWG,INPUT.NM);
end
