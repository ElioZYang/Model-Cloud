function[Nu]=mc_pmsm_ind_Nu_airgap(rho,mu,omega,rm,g)
Ta=rho^2*omega^2*rm*g^3/mu^2;
if Ta<1700
    Nu=2;
elseif Ta<1E4
    Nu=.128*Ta^.367;
else
    Nu=.409*Ta^.241;
end