function mc_record(kind, snapshot)
global MC_DIAG
if isempty(MC_DIAG), return; end
MC_DIAG.sequence=MC_DIAG.sequence+1;
snapshot.stage=MC_DIAG.stage;
snapshot.sequence=MC_DIAG.sequence;
snapshot.kind=kind;
snapshot.anomalies=mc_find_anomalies(snapshot,'snapshot');
file=sprintf('%04d_%s_%s.mat',snapshot.sequence,snapshot.stage,kind);
save(fullfile(MC_DIAG.directory,file),'snapshot','-v7.3');
entry=struct('sequence',snapshot.sequence,'stage',snapshot.stage,'kind',kind, ...
    'file',file,'anomalies',snapshot.anomalies);
if strcmp(kind,'error')
    entry.identifier=snapshot.identifier; entry.message=snapshot.message;
end
if isfield(snapshot,'diagnostics'), entry.diagnostics=snapshot.diagnostics; end
if isfield(entry,'diagnostics')
    entry.diagnostics=rmfield_if_present(entry.diagnostics,{'fval','output'});
end
f=fopen(fullfile(MC_DIAG.directory,'progress.jsonl'),'a');
cleanup=onCleanup(@() fclose(f)); %#ok<NASGU>
fprintf(f,'%s\n',jsonencode(entry));
end
function value=rmfield_if_present(value,names)
for k=1:numel(names), if isfield(value,names{k}), value=rmfield(value,names{k}); end, end
end
