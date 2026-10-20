function component_engine_envelope_validate_count(value, name)
%COMPONENT_ENGINE_ENVELOPE_VALIDATE_COUNT Validate a scan point count.
if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value) || ...
        value <= 0 || value ~= round(value)
    error('engine:InvalidInput', '%s must be a positive integer.', name);
end
end
