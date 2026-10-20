function DP = component_engine_apply_design_conditions(DP, thrust, WA, PWG)
%COMPONENT_ENGINE_APPLY_DESIGN_CONDITIONS Apply explicit design targets.
% Values are assigned verbatim.  Empty, non-scalar, non-finite, or otherwise
% incompatible values remain visible to the legacy solver's native behaviour.
if isfield(DP, 'NS') && DP.NS == 0 && any(PWG(:) ~= 0)
    error('engine:PowerRequiresShaftGroup', ...
        'Nonzero generator power was supplied, but the physical assembly has no shaft groups. Create and configure a shaft group first.');
end
DP.THRUST = thrust;
DP.WA = WA;
DP.PWG = PWG;
end
