function motorModel=mc_pmsm_c_apply_thermal(motorModel,thermalGeometry,thermalBoundary,thermalResult,outletFlow)
if thermalBoundary.mode=="design"
    motorModel.geometry.AN=thermalGeometry.Area;
    motorModel.geometry.hpcgv_OD=2*(thermalGeometry.Rho+thermalGeometry.H_cgv)*1000;
end
motorModel.thermal.thermal_resistance=thermalResult.thermal_resistance;
motorModel.thermal.temp_balance=thermalResult.temp_balance;
motorModel.thermal.dT_air=thermalResult.dT_air*outletFlow.EFF;
motorModel.thermal.dT_pmsm_partial=thermalResult.dT_pmsm_partial;
motorModel.thermal.dH_pmsm_partial=thermalResult.dH_pmsm_partial;
end
