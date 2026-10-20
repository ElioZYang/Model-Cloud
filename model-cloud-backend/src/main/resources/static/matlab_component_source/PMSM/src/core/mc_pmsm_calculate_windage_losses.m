function[P_windage]=mc_pmsm_calculate_windage_losses(rho,mu,omega,D_or,D_ir,L,gap)
    Re_airgap=rho*omega*D_or*gap/2/mu;
    if Re_airgap<64
         Cm_airgap=10*(2*gap/D_or)^.3/Re_airgap;
    elseif Re_airgap<500
         Cm_airgap=2*(2*gap/D_or)^.3/Re_airgap^.6;
    elseif Re_airgap<1e4
         Cm_airgap=1.03*(2*gap/D_or)^.3/Re_airgap^.5;
    else
         Cm_airgap=.065*(2*gap/D_or)^.3/Re_airgap^.2;
    end
    P_windage1=1/32*Cm_airgap*pi*rho*omega^3*D_or^4*L;
    Re_tip=rho*omega*D_or^2/4/mu;
    if Re_tip<3e5
        Cm_tip=3.87/Re_tip^.5;
    else
        Cm_tip=.146/Re_tip^.2;
    end
    P_windage2=1/64*Cm_tip*rho*omega^3*(D_or^5-D_ir^5);
    P_windage=P_windage2+P_windage1;
end