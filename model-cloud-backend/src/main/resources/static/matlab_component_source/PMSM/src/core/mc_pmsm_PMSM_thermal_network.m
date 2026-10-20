function OUTPUT=mc_pmsm_PMSM_thermal_network(INPUT)
model=INPUT.pmsm_params; values=model.thermal.temp_values; names=model.thermal.temp_variables;
refTPR=1; refWCOR=1;
if isfield(INPUT,'TPR'), refTPR=INPUT.TPR; end
if isfield(INPUT,'WCOR'), refWCOR=INPUT.WCOR; end
b=mc_pmsm_c_boundary(INPUT.T,INPUT.P,INPUT.WA,INPUT.FAR,INPUT.D,INPUT.EFFH,...
    values(strcmpi(names,'temp_Fe')),values(strcmpi(names,'temp_Cu')),[false;false],INPUT.mode,refTPR,refWCOR);
g=mc_pmsm_c_thermal_geometry(model); f=mc_pmsm_c_flow(g,b); material=mc_pmsm_c_material(model,g);
switch model.input.cooling
case 1, [network,cooling,model]=mc_pmsm_c_network_air(model,g,f,material,b);
case 2, [network,cooling,model]=mc_pmsm_c_network_hpcgv(model,g,f,material,b);
case 3, [network,cooling,model]=mc_pmsm_c_network_liquid(model,g,f,material,b);
otherwise, error('PMSM:InvalidCooling','Unsupported cooling');
end
thermal=mc_pmsm_c_solve(network);
outlet=mc_pmsm_c_outlet(model,g,b,f,cooling,thermal);
model=mc_pmsm_c_apply_thermal(model,g,b,thermal,outlet);
OUTPUT=INPUT; OUTPUT.T=outlet.T; OUTPUT.P=outlet.P;
OUTPUT.TPR=outlet.TPR; OUTPUT.WCOR=outlet.WCOR; OUTPUT.pmsm_params=model;
end
