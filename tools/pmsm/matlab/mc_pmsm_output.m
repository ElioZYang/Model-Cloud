function OUTPUT=mc_pmsm_output(state)
OUTPUT=state.OUTPUT;
params=OUTPUT.pmsm_params;
OUTPUT.PWG=params.performance.power/1000;
OUTPUT.PWS=params.performance.mechanical_power/1000;
OUTPUT.PWH=params.losses.total/1000;
values=[OUTPUT.PWG,OUTPUT.PWS,OUTPUT.PWH,OUTPUT.T,OUTPUT.P,...
    OUTPUT.TPR,OUTPUT.WCOR,params.performance.efficiency];
if ~isreal(values)||any(~isfinite(values))||OUTPUT.P<=0||OUTPUT.T<=0||OUTPUT.WA<=0||...
        OUTPUT.TPR<=0||params.performance.efficiency<=0||params.performance.efficiency>1
    error('PMSM:InfeasibleOperatingPoint','PMSM produced a complex, nonfinite or nonphysical operating point.');
end
end
