function OUTPUT=mc_pmsm_invoke(INPUT,program_id)
if isempty(program_id)
    entries=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'default-program.json')));
else
    entries=mc_pmsm_program_registry('get',program_id);
end
entry=char(string(INPUT.mode));
if ~isfield(entries,entry), error('PMSM:MissingEntrypoint','Missing PMSM entrypoint: %s',entry); end
mc_pmsm_program_registry('error-clear','');
try
    [OUTPUT,nodes]=mc_pmsm_execute_program(entries.(entry),INPUT);
catch cause
    detail=mc_pmsm_program_registry('error','');
    detail.programId=program_id; detail.entrypoint=entry;
    mc_pmsm_program_registry('error-record',detail);
    rethrow(cause);
end
if ~isempty(program_id)
    mc_pmsm_program_registry('record',struct('programId',program_id,'entrypoint',entry,'nodes',{nodes}));
end
end
