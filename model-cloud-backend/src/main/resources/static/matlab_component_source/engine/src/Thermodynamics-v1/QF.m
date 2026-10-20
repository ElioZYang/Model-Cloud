%流函数
function [Q] = QF(VC,K)
Q=((K+1)/2)^(1/(K-1))*VC*(-2/(K-1))^(1/(K-1));
end