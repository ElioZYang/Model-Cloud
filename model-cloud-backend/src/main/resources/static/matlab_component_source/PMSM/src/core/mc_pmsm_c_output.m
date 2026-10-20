function OUTPUT=mc_pmsm_c_output(INPUT,motorModel,outletFlow)
OUTPUT=INPUT;
OUTPUT.T=outletFlow.T; OUTPUT.P=outletFlow.P;
OUTPUT.TPR=outletFlow.TPR; OUTPUT.WCOR=outletFlow.WCOR;
OUTPUT.pmsm_params=motorModel;
OUTPUT.PWG=motorModel.performance.power/1000;
OUTPUT.PWS=motorModel.performance.mechanical_power/1000;
OUTPUT.PWH=motorModel.losses.total/1000;
values=[OUTPUT.PWG,OUTPUT.PWS,OUTPUT.PWH,OUTPUT.T,OUTPUT.P,...
    OUTPUT.TPR,OUTPUT.WCOR,motorModel.performance.efficiency];
if ~isreal(values)||any(~isfinite(values))||OUTPUT.P<=0||OUTPUT.T<=0||OUTPUT.WA<=0||...
    OUTPUT.TPR<=0||motorModel.performance.efficiency<=0||motorModel.performance.efficiency>1
    error('PMSM:InfeasibleOperatingPoint','PMSM produced a complex, nonfinite or nonphysical operating point.');
end
end
