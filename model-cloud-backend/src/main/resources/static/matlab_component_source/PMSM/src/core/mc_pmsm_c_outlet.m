function outletFlow=mc_pmsm_c_outlet(motorModel,thermalGeometry,thermalBoundary,flowState,coolingFlow,thermalResult)
g=thermalGeometry; b=thermalBoundary; f=flowState; EFF=b.EFFH;
if motorModel.input.cooling==3, EFF=0; end
switch b.mode
case 'design'
    dP=mc_pmsm_calculate_annular_cascade_loss(f.Vel,2*g.Ro,2*g.Ro+2*g.H_cgv,g.N_slot,g.H_cgv,0,...
        g.C_cgv,coolingFlow.Re_cgv,f.M_in,0,0,f.rhos);
    TPR=1-dP/b.P*EFF;
case 'offdesign'
    TPR=1-(1-b.TPR_ref)*(f.WCOR/b.WCOR_ref)^2*EFF;
otherwise, error('PMSM:InvalidMode','Unsupported flow reference mode');
end
outletFlow=struct('T',b.T+thermalResult.dT_air*EFF,'P',b.P*TPR,'WA',f.WA,...
    'TPR',TPR,'WCOR',f.WCOR,'EFF',EFF);
end
