function[P_extra]=mc_pmsm_calculate_extra_losses(P_rated)
if P_rated<=1e3
    P_extra=.025*P_rated;
elseif P_rated<1e7
    P_extra=(.025-.005*log10(P_rated/1000))*P_rated;
else
    P_extra=.005*P_rated;
end
end