function[mu]=mc_pmsm_ind_MU(Ts)
    mu=1.458e-6*Ts.^(3/2)./(Ts+110.4);
end