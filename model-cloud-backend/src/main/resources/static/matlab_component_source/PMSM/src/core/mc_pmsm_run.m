function result=mc_pmsm_run(request)
% Independent, explicit-input PMSM API. No changes to pwd or base workspace.
% mode: design/offdesign/thermal; power_kw, speed_rpm, config_file;
% flow: T [K], P [Pa], WA [kg/s], FAR, D, EFFH;
% design_model: design result for offdesign/thermal;
% temperatures_C and free_temperature_mask: optional thermal boundaries.
if ~isstruct(request)||~isfield(request,'mode')
    error('PMSM:MissingMode','request.mode is required.');
end
mode=char(string(request.mode));
flow=request.flow;
for name=["T","P","WA","FAR","D","EFFH"]
    if ~isfield(flow,name)||~isnumeric(flow.(name))||~isscalar(flow.(name))||...
            ~isreal(flow.(name))||~isfinite(flow.(name))
        error('PMSM:InvalidFlow','A finite real flow.%s is required.',name);
    end
end
if flow.WA<=0||flow.P<=0||flow.T<=0||flow.EFFH<0||flow.EFFH>1
    error('PMSM:InvalidFlow','Positive flow, pressure, temperature and EFFH in [0,1] are required.');
end
INPUT=flow;
INPUT.mode=string(mode);
switch mode
case 'design'
    file=''; if isfield(request,'config_file'), file=request.config_file; end
    INPUT.pmsm_input=mc_pmsm_read_configuration(file);
    INPUT.PWG=request.power_kw; INPUT.NM=request.speed_rpm;
case 'offdesign'
    INPUT.pmsm_input=request.design_model;
    INPUT.PWG=request.power_kw; INPUT.PWG_ref=1;
    INPUT.NM=request.speed_rpm; INPUT.N_ref=1;
    INPUT.TPR=request.design_model.thermal.design_TPR;
    INPUT.WCOR=request.design_model.thermal.design_WCOR;
case 'thermal'
    INPUT.pmsm_params=request.design_model;
otherwise
    error('PMSM:InvalidMode','Unsupported PMSM mode: %s',mode);
end
field='pmsm_input'; if strcmp(mode,'thermal'), field='pmsm_params'; end
if isfield(request,'temperatures_C')
    INPUT.(field).thermal.temp_values=request.temperatures_C(:);
end
free=false(2,1);
if isfield(request,'free_temperature_mask'), free=logical(request.free_temperature_mask(:)); end
if numel(free)~=2, error('PMSM:InvalidBoundary','Two thermal boundary flags are required.'); end
INPUT.free_temperature_mask=free;
programs=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'default-program.json')));
entry=mode;
temperature=INPUT.(field).thermal.temp_values(:);
if numel(temperature)~=2||any(~isfinite(temperature))||~isreal(temperature)
    error('PMSM:InvalidBoundary','Two finite real node temperatures in Celsius are required.');
end
solver=struct('exitflag',1,'normalizedResidual',0,'solvedNodes',free);
if any(free)
    options=optimoptions('fsolve','Display','off');
    [temperature(free),residual,exitflag]=fsolve(@balance,temperature(free),options);
    solver.exitflag=exitflag;
    solver.normalizedResidual=max(abs(residual));
    if exitflag<=0||solver.normalizedResidual>1e-6
        error('PMSM:ThermalNotConverged','Thermal solve failed: exitflag=%d, residual=%g.',exitflag,solver.normalizedResidual);
    end
end
INPUT.(field).thermal.temp_values=temperature;
result=mc_pmsm_execute_program(programs.(entry),INPUT);
result.solver=solver;
if strcmp(mode,'design')
    result.pmsm_params.thermal.design_TPR=result.TPR;
    result.pmsm_params.thermal.design_WCOR=result.WCOR;
end
    function residual=balance(candidate)
        trial=INPUT; values=temperature; values(free)=candidate;
        trial.(field).thermal.temp_values=values;
        output=mc_pmsm_execute_program(programs.(entry),trial);
        residual=output.pmsm_params.thermal.dT_pmsm_partial(free);
    end
end
