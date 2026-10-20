function diagnostics=component_engine_pmsm_diagnostics(DP,state,diagnostics,mode)
% Supplement the original solver with unit-scaled acceptance diagnostics.
if strcmp(mode,'design')
    residual=double(state.YD(:)); scales=ones(size(residual));
    % The original nozzle pressure residual is already a pressure ratio.
    first=1+(DP.WA<=0);
    count=sum(DP.PRT<=0);
    if count>0, scales(first:first+count-1)=max(1,max(abs(DP.PWG))); end
else
    residual=double(state.YO(:)); scales=ones(size(residual));
    labels=string(state.YO_element(:));
    scales(labels=="shaft power")=max(1,max(abs(DP.PWG)));
    % Gas-path and thrust residuals are already normalized by the model.
end
diagnostics.normalized_residual=0;
if ~isempty(residual), diagnostics.normalized_residual=max(abs(residual)./scales); end
diagnostics.converged=isreal(residual)&&all(isfinite(residual))&&...
    diagnostics.exitflag>0&&diagnostics.normalized_residual<=1e-6;
if ~diagnostics.converged
    error('engine:PmsmMatchingNotConverged','PMSM matching did not converge: exitflag=%d, normalized residual=%g.',...
        diagnostics.exitflag,diagnostics.normalized_residual);
end
end
