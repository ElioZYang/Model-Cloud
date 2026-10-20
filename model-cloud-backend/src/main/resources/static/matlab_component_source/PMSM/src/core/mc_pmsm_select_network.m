function state=mc_pmsm_select_network(state)
switch state.cooling
case 1, state=mc_pmsm_network_air(state);
case 2, state=mc_pmsm_network_hpcgv(state);
case 3, state=mc_pmsm_network_liquid(state); state.EFF=0;
otherwise, error('PMSM:InvalidCooling','Unsupported cooling mode');
end
end
