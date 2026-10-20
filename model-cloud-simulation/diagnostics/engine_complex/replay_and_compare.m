function replay_and_compare(compareOnly)
if nargin > 0 && compareOnly
    compare_runs(getenv('MC_DIAG_OUTPUT'));
    return;
end
global MC_DIAG
output=getenv('MC_DIAG_OUTPUT'); root=getenv('ENGINE_PLATFORM_ROOT');
helpers=fileparts(mfilename('fullpath'));
restoredefaultpath;cd(root);addpath(genpath(root));addpath(helpers,'-begin');
trace=fullfile(output,'trace');addpath(trace,'-begin');clear DESIGN OFFDESIGN
directory=fullfile(output,'replay');if ~isfolder(directory),mkdir(directory);end
MC_DIAG=struct('sequence',0,'stage','design_replay','directory',directory);
data=load(fullfile(output,'platform','run','0002_design_design.mat'));
saved=data.snapshot;
evalc('[residual,replayed]=DESIGN(saved.X(saved.LM),saved.inputDP);');
assert(isequaln(replayed.THRUST_REF,saved.result.THRUST_REF));
mc_record('replayed',struct('result',replayed,'residual',residual));
MC_DIAG.stage='offdesign_replay';
data=load(fullfile(output,'platform','run','0003_offdesign_init_offdesign.mat'));saved=data.snapshot;
evalc('[residual,replayed]=OFFDESIGN(saved.X(saved.LM),saved.DP,saved.inputOP);');
assert(isequaln(replayed.THRUST_REF,saved.result.THRUST_REF));
mc_record('replayed',struct('result',replayed,'residual',residual));
for k=1:MC_DIAG.sequence
    files=dir(fullfile(directory,sprintf('%04d_*_formula.mat',k)));
    if ~isempty(files)
        data=load(fullfile(directory,files(1).name)); s=data.snapshot;
        fprintf('%s WA=%.17g V=%.17g PW_REF=%.17g radicand=%.17g THRUST_REF=%s\n', ...
            s.stage,s.WA,s.V,s.PW_REF,s.radicand,mat2str(s.THRUST_REF,17));
    end
end
% Synthetic metadata checks do not run an engine model.
sample=struct('s',1+2i,'m',[1 2+3i;4 5],'nested',{{struct('x',6+7i)}});
fields=component_matlab_complex_fields(sample);
assert(isequal({fields.path},{'$.s','$.m','$.nested{1}.x'}));
assert(isequal(fields(2).shape,[2 2]) && isequal(fields(2).indices,3));
assert(isempty(component_matlab_complex_fields(struct('real',[1 2 3]))));
jsonencode(fields);
fprintf('complex metadata synthetic checks passed\n');
compare_runs(output);
end

function compare_runs(output)
a=dir(fullfile(output,'original','run','*.mat'));
b=dir(fullfile(output,'platform','run','*.mat'));
report=struct('originalCount',numel(a),'platformCount',numel(b),'comparisons',{{}});
for k=1:min(numel(a),numel(b))
    left=load(fullfile(a(k).folder,a(k).name));right=load(fullfile(b(k).folder,b(k).name));
    left=left.snapshot;right=right.snapshot;
    entry=struct('stage',left.stage,'kind',left.kind,'match',true,'differences',{{}});
    assert(strcmp(left.stage,right.stage) && strcmp(left.kind,right.kind));
    for field={'result','X','rawX','DX','residual','identifier','message'}
        name=field{1};
        if isfield(left,name) && isfield(right,name)
            entry.differences=[entry.differences,compare_values(left.(name),right.(name),name)];
        end
    end
    entry.match=isempty(entry.differences);
    report.comparisons{end+1}=entry;
end
f=fopen(fullfile(output,'comparison.json'),'w');cleanup=onCleanup(@()fclose(f)); %#ok<NASGU>
fprintf(f,'%s',jsonencode(report));
fprintf('compared %d snapshot pairs; differing pairs=%d\n',numel(report.comparisons), ...
    nnz(cellfun(@(entry)~entry.match,report.comparisons)));
end

function differences=compare_values(a,b,path)
differences={};
if isnumeric(a) && isnumeric(b)
    if ~strcmp(class(a),class(b)) || isreal(a) ~= isreal(b) || ~isequal(size(a),size(b)) ...
            || ~isequal(isnan(a),isnan(b)) || ~isequal(isinf(a),isinf(b)) ...
            || ~isequal(a(isinf(a)),b(isinf(b)))
        differences={path};return;
    end
    mask=isfinite(a)&isfinite(b);
    if any(abs(a(mask)-b(mask))>1e-8+1e-6*abs(b(mask))),differences={path};end
elseif isstruct(a) && isstruct(b)
    if ~isequal(size(a),size(b)) || ~isequal(sort(fieldnames(a)),sort(fieldnames(b)))
        differences={path};return;
    end
    names=fieldnames(a);
    for j=1:numel(a),for k=1:numel(names)
        differences=[differences,compare_values(a(j).(names{k}),b(j).(names{k}),[path '.' names{k}])]; %#ok<AGROW>
    end,end
elseif iscell(a)&&iscell(b)
    if ~isequal(size(a),size(b)),differences={path};return;end
    for k=1:numel(a),differences=[differences,compare_values(a{k},b{k},sprintf('%s{%d}',path,k))];end %#ok<AGROW>
elseif ~isequaln(a,b)
    differences={path};
end
end
