function[O]=mc_pmsm_TOTAL_PRESSURE(M,K)
O=1+(K-1)/2*M^2;
O=O^(K/(K-1));
end