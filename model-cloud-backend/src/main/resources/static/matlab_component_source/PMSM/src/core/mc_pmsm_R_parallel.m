function[R]=mc_pmsm_R_parallel(R_in)
R=1./sum(1./R_in);
end