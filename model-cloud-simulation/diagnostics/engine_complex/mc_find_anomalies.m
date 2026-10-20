function records = mc_find_anomalies(value, prefix)
% Preserve every returned complex/nonfinite leaf without converting its value.
records = struct('path',{},'shape',{},'complex',{},'nonfinite',{},'indices',{},'imaginary',{});
if isnumeric(value)
    complex = ~isreal(value);
    bad = ~isfinite(value);
    if complex || any(bad(:))
        indices = find(imag(value) ~= 0 | bad);
        indices = indices(1:min(12,numel(indices)));
        imaginary = imag(value(indices));
        imaginary(~isfinite(imaginary)) = NaN;
        records = struct('path',prefix,'shape',size(value),'complex',complex, ...
            'nonfinite',nnz(bad),'indices',indices(:)','imaginary',imaginary(:)');
    end
elseif isstruct(value)
    fields = fieldnames(value);
    for j=1:numel(value)
        base=prefix;
        if numel(value)>1, base=sprintf('%s(%d)',prefix,j); end
        for k=1:numel(fields)
            records=[records,mc_find_anomalies(value(j).(fields{k}),[base '.' fields{k}])]; %#ok<AGROW>
        end
    end
elseif iscell(value)
    for k=1:numel(value)
        records=[records,mc_find_anomalies(value{k},sprintf('%s{%d}',prefix,k))]; %#ok<AGROW>
    end
end
end
