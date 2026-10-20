function fields = component_matlab_complex_fields(value)
%COMPONENT_MATLAB_COMPLEX_FIELDS Locate complex leaves for error reporting.
% Values remain in MATLAB; this returns only real-valued diagnostic metadata.
fields = visit(value, '$');
end

function fields = visit(value, path)
fields = struct('path', {}, 'className', {}, 'shape', {}, ...
    'indices', {}, 'realValues', {}, 'imaginaryValues', {});
if isnumeric(value) && ~isreal(value)
    indices = find(imag(value) ~= 0);
    indices = indices(1:min(8, numel(indices)));
    samples = value(indices);
    realValues = real(samples);
    imaginaryValues = imag(samples);
    fields = struct('path', path, 'className', class(value), ...
        'shape', size(value), 'indices', indices(:)', ...
        'realValues', realValues(:)', ...
        'imaginaryValues', imaginaryValues(:)');
elseif isstruct(value)
    names = fieldnames(value);
    for index = 1:numel(value)
        prefix = path;
        if numel(value) > 1, prefix = sprintf('%s(%d)', path, index); end
        for k = 1:numel(names)
            fields = [fields, visit(value(index).(names{k}), ...
                [prefix '.' names{k}])]; %#ok<AGROW>
        end
    end
elseif iscell(value)
    for index = 1:numel(value)
        fields = [fields, visit(value{index}, ...
            sprintf('%s{%d}', path, index))]; %#ok<AGROW>
    end
end
end
