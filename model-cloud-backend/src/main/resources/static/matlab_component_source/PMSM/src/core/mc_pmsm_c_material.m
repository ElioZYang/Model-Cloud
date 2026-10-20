function materialProperties=mc_pmsm_c_material(motorModel,thermalGeometry)
mat=motorModel.input.material.data;
k_iso=mc_pmsm_get_prop(mat,'iso','thermal_conductivity');
k_cu=mc_pmsm_get_prop(mat,'copper','thermal_conductivity');
k_stator=mc_pmsm_get_prop(mat,'steel','thermal_conductivity');
k_housing=mc_pmsm_get_prop(mat,'aluminum','thermal_conductivity');
k_cavity=mc_pmsm_get_prop(mat,'cavity','thermal_conductivity');
materialProperties=struct('t_iso',.2*1e-3,'k_iso',k_iso,'k_cu',k_cu,'k_stator',k_stator,...
    'k_housing',k_housing,'k_cavity',k_cavity,...
    'k_slot',k_cu*thermalGeometry.slot_fill+k_cavity*(1-thermalGeometry.slot_fill));
end
