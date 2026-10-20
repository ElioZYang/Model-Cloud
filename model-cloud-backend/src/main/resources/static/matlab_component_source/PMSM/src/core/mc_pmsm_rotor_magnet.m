function state = mc_pmsm_rotor_magnet(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'B_g_eq'), B_g_eq=state.B_g_eq; end
if isfield(state,'B_g_pm'), B_g_pm=state.B_g_pm; end
if isfield(state,'Br'), Br=state.Br; end
if isfield(state,'D_ir'), D_ir=state.D_ir; end
if isfield(state,'D_is'), D_is=state.D_is; end
if isfield(state,'D_or'), D_or=state.D_or; end
if isfield(state,'Hcj'), Hcj=state.Hcj; end
if isfield(state,'K_arc'), K_arc=state.K_arc; end
if isfield(state,'K_carter'), K_carter=state.K_carter; end
if isfield(state,'L'), L=state.L; end
if isfield(state,'P_mag'), P_mag=state.P_mag; end
if isfield(state,'X_rotor'), X_rotor=state.X_rotor; end
if isfield(state,'f_elec'), f_elec=state.f_elec; end
if isfield(state,'gap'), gap=state.gap; end
if isfield(state,'h_pm'), h_pm=state.h_pm; end
if isfield(state,'h_pm_max'), h_pm_max=state.h_pm_max; end
if isfield(state,'mag_params'), mag_params=state.mag_params; end
if isfield(state,'magnet'), magnet=state.magnet; end
if isfield(state,'material_data'), material_data=state.material_data; end
if isfield(state,'n_rated'), n_rated=state.n_rated; end
if isfield(state,'pole_pairs'), pole_pairs=state.pole_pairs; end
if isfield(state,'slot_params'), slot_params=state.slot_params; end
    Br=mc_pmsm_get_prop(material_data,magnet,'B_r');
    Hcj=mc_pmsm_get_prop(material_data,magnet,'H_cj');
    h_pm_max=D_is/2-1e-3;
    [h_pm] = mc_pmsm_calculate_pm_thickness(D_is, L, gap, ...
        B_g_pm, Br, Hcj, K_carter, pole_pairs, K_arc, ...
        slot_params.opening_width/1000, ...
        slot_params.opening_height/1000);
    if h_pm>h_pm_max
    gap=gap*h_pm_max/h_pm;
    h_pm=h_pm_max;
    end
    D_or = D_is - 2*gap;  % 转子外径更新
    D_ir=D_or*X_rotor;

    mag_params.outer_diameter=1000*D_or;
    mag_params.pole_pairs=pole_pairs;
    mag_params.volume=L*pi*((D_or/2)^2-(D_or/2-h_pm)^2)*K_arc;
    mag_params.height=1000*h_pm;
    mag_params.theta=K_arc*360/2/pole_pairs;
    mag_params.segments=1;
    P_mag=0;
    P_mag=mc_pmsm_calculate_magnet_losses_offdesign(mag_params, f_elec, B_g_eq, n_rated);

if exist('Br','var') && ~isa(Br,'function_handle'), state.Br=Br; end
if exist('D_ir','var') && ~isa(D_ir,'function_handle'), state.D_ir=D_ir; end
if exist('D_or','var') && ~isa(D_or,'function_handle'), state.D_or=D_or; end
if exist('Hcj','var') && ~isa(Hcj,'function_handle'), state.Hcj=Hcj; end
if exist('P_mag','var') && ~isa(P_mag,'function_handle'), state.P_mag=P_mag; end
if exist('gap','var') && ~isa(gap,'function_handle'), state.gap=gap; end
if exist('h_pm','var') && ~isa(h_pm,'function_handle'), state.h_pm=h_pm; end
if exist('h_pm_max','var') && ~isa(h_pm_max,'function_handle'), state.h_pm_max=h_pm_max; end
if exist('mag_params','var') && ~isa(mag_params,'function_handle'), state.mag_params=mag_params; end
end
