function cp = mc_pmsm_ind_steel_heat_capacity(T)
    % 温度-比热容关系（线性近似）
    if T <= 293
        cp = 460;
    elseif T <= 373
        cp = 460 + (520-460)*(T-293)/80;
    else
        cp = 520 + (580-520)*(T-373)/100;
    end
end