% 周向热阻
function[Rt]=mc_pmsm_Rt_cyn(ri,ro,theta,l,k)
Rt=theta*(ro+ri)/2/(k*l*(ro-ri));
end