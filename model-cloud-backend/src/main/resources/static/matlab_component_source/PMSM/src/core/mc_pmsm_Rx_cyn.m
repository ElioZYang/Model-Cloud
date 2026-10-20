% 轴向热阻
function[Rx]=mc_pmsm_Rx_cyn(ri,ro,theta,l,k)
Ac=(ro^2-ri^2)*theta/2;
Rx=l/k/Ac;
end