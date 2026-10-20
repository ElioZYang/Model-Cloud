function run_diagnostic()
global MC_DIAG
output=getenv('MC_DIAG_OUTPUT');
helpers=fileparts(mfilename('fullpath'));
roots={getenv('ENGINE_DEMO_ROOT'),getenv('ENGINE_PLATFORM_ROOT')};
labels={'original','platform'};
for side=1:2
    selected=getenv('MC_DIAG_SIDE');
    if ~isempty(selected) && ~strcmp(selected,labels{side}), continue; end
    root=roots{side}; label=labels{side};
    restoredefaultpath; cd(root); addpath(genpath(root)); addpath(helpers,'-begin');
    override=fullfile(output,label,'override'); setenv('MC_DIAG_OVERRIDE',override);
    addpath(override,'-begin'); clear BALANCE_FUNCTION_DESIGN BALANCE_FUNCTION_OFFDESIGN component_engine_envelope_scope
    directory=fullfile(output,label,'run'); if ~isfolder(directory), mkdir(directory); end
    MC_DIAG=struct('sequence',0,'stage','initialize','directory',directory);
    try
        if side==1
            DP=struct('V',60,'M',0,'H',3000,'V_max',60,'H_max',3000,'type','separated turbofan');
            evalc('DP=INPUT_DESIGN_PARAMETERS(DP);');
        else
            assembly=fileread(fullfile(output,'assembly.json'));
            evalc('DP=component_engine_initialize_configuration(assembly,60,0,3000);');
        end
        DP.display=0; DP.THRUST=0; DP.WA=0; DP.PWG=0;
        initialized=DP;
        mc_record('initialize',struct('result',DP));
        MC_DIAG.stage='design'; evalc('[DP,XD]=BALANCE_FUNCTION_DESIGN(DP,0);');
        if side==2
            MC_DIAG.stage='offdesign_init'; evalc('state=component_engine_envelope_initialize(DP);');
            MC_DIAG.stage='power'; evalc('[state,mission_power]=component_engine_envelope_power(state,20);');
            MC_DIAG.stage='speed_reset'; evalc('state=component_engine_envelope_speed_initialize(state);');
            MC_DIAG.stage='speed'; evalc('state=component_engine_envelope_speed(state,100);');
            MC_DIAG.stage='altitude'; evalc('state=component_engine_envelope_altitude(state,100);');
            evalc('[mission,thrust,tit,comp,turb,motor,OP,X0,DX]=component_engine_envelope_finalize(state);');
        else
            MAP=READMAP(DP); OP=DP; X0=0; DX=0;
            thrust=[];tit=[];comp=[];turb=[];motor=[];
            MC_DIAG.stage='offdesign_init'; evalc('[OP,X0,~]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0);');
            ratios=linspace(1,.01,20); MC_DIAG.stage='power';
            for k=1:20
                OP.N_ref=-DP.N_ref; OP.PWG(1)=DP.PWG(1); OP.PWG(1)=ratios(k)*DP.PWG(1);
                evalc('[OP,X0,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0+0.0*DX);');
                [thrust,tit,comp,turb,motor]=append(thrust,tit,comp,turb,motor,OP);
            end
            mission_power=struct('G',struct('DP',DP,'MAP',MAP,'COMP_WP',comp,'TURB_WP',turb,'MOTOR_WP',motor));
            MC_DIAG.stage='speed_reset'; OP=DP;X0=0;evalc('[OP,X0,~]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0);');
            MC_DIAG.stage='speed';
            for k=1:100
                OP.V=OP.V-DP.V_max/100;OP.N_ref=-DP.N_ref;OP.PWG=DP.PWG;
                evalc('[OP,X0,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0+0.0*DX);');
                [thrust,tit,comp,turb,motor]=append(thrust,tit,comp,turb,motor,OP);
            end
            MC_DIAG.stage='altitude';
            for k=1:100
                OP.H=OP.H-DP.H_max/100;OP.N_ref=-DP.N_ref;OP.PWG=DP.PWG;
                evalc('[OP,X0,DX]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0+0.0*DX);');
                [thrust,tit,comp,turb,motor]=append(thrust,tit,comp,turb,motor,OP);
            end
            mission=struct('G',struct('DP',DP,'MAP',MAP,'COMP_WP',comp,'TURB_WP',turb,'MOTOR_WP',motor));
        end
        MC_DIAG.stage='final';
        final=struct('DP',DP,'XD',XD,'MISSION',mission,'MISSION_power',mission_power, ...
            'THRUST',thrust,'TIT',tit,'COMP',comp,'TURB',turb,'MOTOR',motor,'OP',OP,'X0',X0,'DX',DX);
        mc_record('outputs',struct('result',final));
        MC_DIAG.stage='serialization';
        try, jsonencode(final); catch exception, mc_record('error',struct('identifier',exception.identifier,'message',exception.message)); end
    catch exception
        mc_record('error',struct('identifier',exception.identifier,'message',getReport(exception,'extended','hyperlinks','off')));
    end
    if exist('initialized','var')
        MC_DIAG.stage='control98'; control=initialized;control.THRUST=98;
        try, evalc('[control,controlXD]=BALANCE_FUNCTION_DESIGN(control,0);');
        catch exception, mc_record('error',struct('identifier',exception.identifier,'message',getReport(exception,'extended','hyperlinks','off'))); end
    end
    fprintf('%s finished: %d snapshots\n',label,MC_DIAG.sequence);
    clear initialized
end
end
function [thrust,tit,comp,turb,motor]=append(thrust,tit,comp,turb,motor,OP)
thrust=[thrust,OP.THRUST];tit=[tit,OP.TO(1)];comp=[comp,OP.COMP_WP];turb=[turb,OP.TURB_WP];motor=[motor,OP.MOTOR_WP];
end
