function request=mc_pmsm_c_request(INPUT)
mode=char(string(INPUT.mode));
switch mode
case 'design'
    configuration=INPUT.pmsm_input; designModel=struct();
    power=INPUT.PWG; speed=INPUT.NM; thermalMode='design'; thermal=configuration.thermal;
case 'offdesign'
    designModel=INPUT.pmsm_input; configuration=designModel.input;
    power=INPUT.PWG*INPUT.PWG_ref; speed=INPUT.NM*INPUT.N_ref;
    thermalMode='offdesign'; thermal=designModel.thermal;
case 'thermal'
    designModel=INPUT.pmsm_params; configuration=designModel.input;
    power=designModel.performance.power/1000; speed=designModel.performance.speed;
    thermalMode='design'; thermal=designModel.thermal;
otherwise, error('PMSM:InvalidMode','Unsupported analysis mode: %s',mode);
end
free=[false;false]; if isfield(INPUT,'free_temperature_mask'), free=INPUT.free_temperature_mask; end
refTPR=1; refWCOR=1;
if isfield(INPUT,'TPR'), refTPR=INPUT.TPR; end
if isfield(INPUT,'WCOR'), refWCOR=INPUT.WCOR; end
request=struct('configuration',configuration,'designModel',designModel,'power_kw',power,'speed_rpm',speed,...
    'T',INPUT.T,'P',INPUT.P,'WA',INPUT.WA,'FAR',INPUT.FAR,'D',INPUT.D,'EFFH',INPUT.EFFH,...
    'temp_Fe',thermal.temp_values(strcmpi(thermal.temp_variables,'temp_Fe')),...
    'temp_Cu',thermal.temp_values(strcmpi(thermal.temp_variables,'temp_Cu')),...
    'free_temperature_mask',free,'thermalMode',thermalMode,'TPR_ref',refTPR,'WCOR_ref',refWCOR);
end
