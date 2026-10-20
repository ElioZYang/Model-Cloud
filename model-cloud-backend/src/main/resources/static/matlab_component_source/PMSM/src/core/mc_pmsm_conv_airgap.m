function[hg]=mc_pmsm_conv_airgap(g,r,omega,mu,k)
hg=k/2/g*0.03*(2*g*omega*r/mu).^0.8;
end
