%流函数
function [Q] = mc_pmsm_QF(mc_pmsm_VC,K)
Q=((K+1)/2)^(1/(K-1))*mc_pmsm_VC*(-2/(K-1))^(1/(K-1));
end