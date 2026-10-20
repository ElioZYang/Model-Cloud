function thermalResult=mc_pmsm_c_solve(thermalNetwork)
n=thermalNetwork;
[rates,temperatures]=mc_pmsm_thermal_balance_solver(n.R,n.C,n.PW_in,n.T_in,n.LM1,n.LM2);
thermalResult=struct('dT_air',rates(1),'dT_pmsm_partial',rates(2:end),'temp_balance',temperatures-273,...
    'thermal_resistance',n.R,'dH_pmsm_partial',[n.Q_Fe;n.Q_Cu].*rates(2:end)/1000);
end
