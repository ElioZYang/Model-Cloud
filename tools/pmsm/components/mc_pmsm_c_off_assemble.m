function motorModel=mc_pmsm_c_off_assemble(designModel,losses,performance)
motorModel=designModel; motorModel.performance=performance; motorModel.losses=losses;
end
