function value=mc_pmsm_program_registry(action,payload)
% Task-local registry. Install once per task; clear even after execution errors.
persistent programs snapshots last_error
if isempty(programs), programs=containers.Map('KeyType','char','ValueType','any'); end
if isempty(snapshots), snapshots=containers.Map('KeyType','char','ValueType','any'); end
if isempty(last_error), last_error=struct(); end
value=[];
switch action
case 'clear'
    programs=containers.Map('KeyType','char','ValueType','any');
    snapshots=containers.Map('KeyType','char','ValueType','any');
    last_error=struct();
case 'install'
    if ischar(payload)||isstring(payload), payload=jsondecode(payload); end
    if iscell(payload), payload=[payload{:}]; end
    for item=payload(:)'
        if isKey(programs,char(item.id)), error('PMSM:DuplicateProgram','Duplicate program id'); end
        programs(char(item.id))=item.entries;
    end
case 'get'
    if ~isKey(programs,char(payload)), error('PMSM:UnknownProgram','Unknown PMSM program: %s',payload); end
    value=programs(char(payload));
case 'record'
    snapshots([char(payload.programId),':',char(payload.entrypoint)])=payload;
case 'snapshots'
    value=values(snapshots);
case 'error-clear'
    last_error=struct();
case 'error-record'
    last_error=payload;
case 'error'
    value=last_error;
otherwise
    error('PMSM:InvalidRegistryAction','Unknown registry action');
end
end
