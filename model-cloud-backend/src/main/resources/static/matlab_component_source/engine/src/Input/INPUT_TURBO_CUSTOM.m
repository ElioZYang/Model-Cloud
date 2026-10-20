function DP = INPUT_TURBO_CUSTOM(DP, assembly)
%INPUT_TURBO_CUSTOM Apply a project-local DP-style physical assembly.
% No physical consistency checks are performed.  Missing or incompatible
% fields are intentionally left for the legacy MATLAB execution to report.
DP = INPUT_TURBO_COMMON_HEAD(DP);

if isfield(assembly, 'fields') && isstruct(assembly.fields)
    assembly = engine_merge_struct(assembly, assembly.fields);
end
if isfield(assembly, 'DP') && isstruct(assembly.DP)
    assembly = engine_merge_struct(assembly, assembly.DP);
end
if isfield(assembly, 'assembly') && isstruct(assembly.assembly)
    assembly = engine_merge_struct(assembly, assembly.assembly);
end
if isfield(assembly, 'parameters') && isstruct(assembly.parameters) && ...
        isscalar(assembly.parameters)
    assembly = engine_merge_struct(assembly, assembly.parameters);
end

skip = {'preset','fields','DP','assembly','components','component_instances', ...
    'instances','parameters','map','maps','shape','type'};
names = fieldnames(assembly);
for k = 1:numel(names)
    name = names{k};
    if any(strcmp(name, skip))
        continue;
    end
    DP.(name) = assembly.(name);
end

% A direct DP-style assembly may carry type as metadata, but it must not
% select a preset after its component fields have been supplied.
if isfield(assembly, 'type') && ~isfield(DP, 'type')
    DP.type = assembly.type;
end
DP = INPUT_TURBO_COMMON_TAIL(DP, DP.NS, DP.NW, length(DP.F));
end

function out = engine_merge_struct(base, overlay)
out = base;
names = fieldnames(overlay);
for k = 1:numel(names)
    out.(names{k}) = overlay.(names{k});
end
end
