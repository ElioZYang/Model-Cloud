function summarize_diagnostic()
root=getenv('MC_DIAG_OUTPUT');
summary=struct();
for side={'original','platform'}
    label=side{1}; folder=fullfile(root,label,'run');
    data=load(fullfile(folder,'0002_design_design.mat')); zero=data.snapshot;
    data=load(fullfile(folder,'0227_control98_design.mat')); control=data.snapshot;
    entry=struct('zeroTarget',describe(zero),'control98',describe(control));
    summary.(label)=entry;
end
data=load(fullfile(root,'platform','run','0003_offdesign_init_offdesign.mat'));
summary.offdesignInput=struct('V',data.snapshot.inputOP.V,'M',data.snapshot.inputOP.M, ...
    'H',data.snapshot.inputOP.H,'PWG',data.snapshot.inputOP.PWG);
f=fopen(fullfile(root,'summary.json'),'w');cleanup=onCleanup(@()fclose(f)); %#ok<NASGU>
fprintf(f,'%s',jsonencode(summary));
disp(jsonencode(summary));
end
function entry=describe(snapshot)
DP=snapshot.result;
entry=struct('WA',DP.WA,'V',DP.V,'M',DP.M,'H',DP.H,'THRUST',DP.THRUST, ...
    'PWG',DP.PWG,'PW_REF',DP.PW_REF,'THRUST_REF_real',real(DP.THRUST_REF), ...
    'THRUST_REF_imag',imag(DP.THRUST_REF),'exitflag',snapshot.diagnostics.exitflag, ...
    'residual_norm',snapshot.diagnostics.residual_norm);
end
