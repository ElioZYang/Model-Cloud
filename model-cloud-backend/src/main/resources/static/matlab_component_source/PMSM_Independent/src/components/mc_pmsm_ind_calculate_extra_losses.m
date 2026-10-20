function extra_loss_W = mc_pmsm_ind_calculate_extra_losses(electric_power_W)

if electric_power_W <= 1e3
    extra_loss_W = .025*electric_power_W;
elseif electric_power_W < 1e7
    extra_loss_W = (.025-.005*log10(electric_power_W/1000)) ...
        * electric_power_W;
else
    extra_loss_W = .005*electric_power_W;
end

end
