function [OUTPUT,snapshot]=mc_pmsm_execute_program(program,INPUT)
% Execute a server-validated program inside MATLAB, including each fsolve call.
if isfield(program,'analysisMode') && ...
        ~strcmp(char(string(program.analysisMode)),char(string(INPUT.mode)))
    error('PMSM:EntrypointModeMismatch','Program mode %s cannot run INPUT.mode %s.',...
        char(string(program.analysisMode)),char(string(INPUT.mode)));
end
nodes=records(program.nodes); edges=records(program.edges);
cache=containers.Map('KeyType','char','ValueType','any');
order=string(program.executionOrder);
for id=order(:)'
    index=find(strcmp(string({nodes.id}),id));
    if numel(index)~=1, error('PMSM:InvalidProgram','Invalid node id: %s',id); end
    node=nodes(index);
    try
        if strcmp(node.componentId,'pmsm.program.input')
            if any(strcmp(string({edges.targetNodeId}),id))
                error('PMSM:InvalidContextInput','Caller INPUT cannot have an internal source.');
            end
            cache(char(id))=struct('INPUT',mc_pmsm_program_input(INPUT)); continue;
        end
        inputs=struct;
        if isfield(node,'values')&&isstruct(node.values), inputs=node.values; end
        for edge=edges
            if strcmp(edge.targetNodeId,id)
                previous=cache(char(edge.sourceNodeId));
                inputs.(edge.targetPort)=previous.(edge.sourcePort);
            end
        end
        if strcmp(node.componentId,'builtin.bus.creator')
            outputs=struct; outputs.(node.outputs(1).name)=inputs;
        elseif strcmp(node.componentId,'builtin.bus.selector')
            error('PMSM:UnsupportedProgramNode','Use typed PMSM state components for subgraph selection.');
        else
            invocation=node.invocation;
            function_name=char(invocation.function);
            if ~startsWith(function_name,'mc_pmsm_')||isempty(regexp(function_name,'^mc_pmsm_[A-Za-z0-9_]+$','once'))
                error('PMSM:InvalidProgramFunction','Only catalog PMSM functions are allowed.');
            end
            definitions=records(invocation.arguments); arguments=cell(1,numel(definitions));
            for k=1:numel(definitions)
                definition=definitions(k);
                if ~strcmp(definition.source,'input')
                    error('PMSM:UnsupportedProgramBinding','PMSM programs require explicit typed input bindings.');
                end
                arguments{k}=inputs.(definition.name);
            end
            returns=records(invocation.returns);
            count=max([returns.returnIndex])+1; values=cell(1,count);
            [values{:}]=feval(function_name,arguments{:});
            outputs=struct;
            for definition=returns
                value=values{definition.returnIndex+1};
                if isfield(definition,'path')&&~isempty(definition.path)
                    for part=split(string(definition.path),'.')', value=value.(part); end
                end
                outputs.(definition.output)=value;
            end
        end
        cache(char(id))=outputs;
    catch cause
        path=char(id);
        if isfield(node,'originPath'), path=strjoin(string(node.originPath),'/'); end
        source=char(id); if isfield(node,'sourceNodeId'), source=node.sourceNodeId; end
        origin={char(id)};
        if isfield(node,'originPath'), origin=cellstr(string(node.originPath)); end
        mc_pmsm_program_registry('error-record',struct('nodeId',char(id),...
            'sourceNodeId',source,'originPath',{origin},'componentId',node.componentId,...
            'exceptionIdentifier',cause.identifier,'message',cause.message));
        exception=MException('PMSM:ProgramNodeFailed','PMSM node %s (%s): %s',path,node.componentId,cause.message);
        throw(addCause(exception,cause));
    end
end
if ~isfield(program,'publicOutputs')||isempty(program.publicOutputs)
    error('PMSM:MissingProgramOutput','Program must expose OUTPUT.');
end
public=records(program.publicOutputs);
names=strings(1,numel(public));
for k=1:numel(public)
    if isfield(public,'displayName')&&~isempty(public(k).displayName)
        names(k)=string(public(k).displayName);
    elseif isfield(public,'name')&&~isempty(public(k).name)
        names(k)=string(public(k).name);
    end
end
index=find(strcmp(names,'OUTPUT'));
if numel(index)~=1, error('PMSM:MissingProgramOutput','Program must expose exactly one OUTPUT.'); end
last=cache(char(public(index).sourceNodeId)); OUTPUT=last.(public(index).sourcePort);
if nargout>1
    snapshot=cell(1,numel(nodes));
    for k=1:numel(nodes)
        node=nodes(k); values=cache(char(node.id)); outputs=struct;
        for definition=records(node.outputs)
            outputs.(definition.name)=values.(definition.name);
        end
        source=node.id; if isfield(node,'sourceNodeId'), source=node.sourceNodeId; end
        origin={node.id}; if isfield(node,'originPath'), origin=node.originPath; end
        snapshot{k}=struct('id',node.id,'sourceNodeId',source,'componentId',node.componentId,...
            'functionName',node.functionName,'originPath',{origin},'status','completed',...
            'availableOutputPorts',{fieldnames(outputs)},'outputs',outputs);
    end
end
end

function result=records(value)
if isempty(value), result=struct([]);
elseif iscell(value)
    names={}; for k=1:numel(value), names=union(names,fieldnames(value{k})); end
    for k=1:numel(value)
        for field=names(:)'
            if ~isfield(value{k},field{1}), value{k}.(field{1})=[]; end
        end
        value{k}=orderfields(value{k},names);
    end
    result=[value{:}];
else, result=value; end
result=reshape(result,1,[]);
end
