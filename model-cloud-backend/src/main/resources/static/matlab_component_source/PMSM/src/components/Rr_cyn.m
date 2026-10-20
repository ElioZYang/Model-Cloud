% 径向热阻
function[Rr]=Rr_cyn(ri,ro,theta,l,k)
Rr=log(ro/ri)/(k*theta*l);
end