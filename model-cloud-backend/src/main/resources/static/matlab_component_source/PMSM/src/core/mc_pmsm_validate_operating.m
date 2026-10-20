function mc_pmsm_validate_operating(power,speed)
if ~isnumeric(power)||~isscalar(power)||~isreal(power)||~isfinite(power)||power==0
error('PMSM:InvalidPower','Power must be a finite nonzero real scalar (kW).'); end
if ~isnumeric(speed)||~isscalar(speed)||~isreal(speed)||~isfinite(speed)||speed<=0
error('PMSM:InvalidSpeed','Speed must be a positive finite real scalar (rpm).'); end
end
