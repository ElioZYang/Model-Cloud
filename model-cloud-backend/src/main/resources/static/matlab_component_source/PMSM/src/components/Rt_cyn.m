% 周向热阻
function[Rt]=Rt_cyn(ri,ro,theta,l,k)
Rt=theta*(ro+ri)/2/(k*l*(ro-ri));
end