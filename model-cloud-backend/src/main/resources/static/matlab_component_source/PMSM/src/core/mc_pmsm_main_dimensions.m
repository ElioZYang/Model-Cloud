function state = mc_pmsm_main_dimensions(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'A_s'), A_s=state.A_s; end
if isfield(state,'A_s_max'), A_s_max=state.A_s_max; end
if isfield(state,'A_slot_min'), A_slot_min=state.A_slot_min; end
if isfield(state,'A_wire'), A_wire=state.A_wire; end
if isfield(state,'B_g_eq'), B_g_eq=state.B_g_eq; end
if isfield(state,'C'), C=state.C; end
if isfield(state,'D2L'), D2L=state.D2L; end
if isfield(state,'DL'), DL=state.DL; end
if isfield(state,'D_is'), D_is=state.D_is; end
if isfield(state,'D_os'), D_os=state.D_os; end
if isfield(state,'I_ph'), I_ph=state.I_ph; end
if isfield(state,'J_max'), J_max=state.J_max; end
if isfield(state,'K_winding'), K_winding=state.K_winding; end
if isfield(state,'L'), L=state.L; end
if isfield(state,'N_cs'), N_cs=state.N_cs; end
if isfield(state,'N_cs_initial'), N_cs_initial=state.N_cs_initial; end
if isfield(state,'N_cs_integer'), N_cs_integer=state.N_cs_integer; end
if isfield(state,'P_rated'), P_rated=state.P_rated; end
if isfield(state,'Q'), Q=state.Q; end
if isfield(state,'T_rated'), T_rated=state.T_rated; end
if isfield(state,'X_length'), X_length=state.X_length; end
if isfield(state,'X_stator'), X_stator=state.X_stator; end
if isfield(state,'a'), a=state.a; end
if isfield(state,'cooling'), cooling=state.cooling; end
if isfield(state,'cos_phi'), cos_phi=state.cos_phi; end
if isfield(state,'k'), k=state.k; end
if isfield(state,'m'), m=state.m; end
if isfield(state,'n_rated'), n_rated=state.n_rated; end
if isfield(state,'pmsm_input'), pmsm_input=state.pmsm_input; end
if isfield(state,'pole_pairs'), pole_pairs=state.pole_pairs; end
if isfield(state,'sigma_max'), sigma_max=state.sigma_max; end
if isfield(state,'slot_fill'), slot_fill=state.slot_fill; end
if isfield(state,'slot_pitch'), slot_pitch=state.slot_pitch; end
%% 主要尺寸计算 (D^2L法)
% C0 = 4*pole_pairs / (pi^2 * K_w * B_g * A_s * cos_phi);
% D_is = (C0 * T_rated).^(1/3);        % 定子内径(m)
C=(pi^2/60 * K_winding * B_g_eq  * n_rated);
sigma_max=48000;
A_s_max=sigma_max/B_g_eq;
if N_cs<0
A_s = pmsm_input.A_s;
A_s = min(A_s_max,A_s);
    % 计算系数k
    k = (a * pi / (I_ph * Q)) * (P_rated / (C * X_length))^(1/3);
    % 计算初始N_cs
    N_cs_initial = k * A_s^(2/3);
    % 取最接近的整数
    N_cs_integer = floor(N_cs_initial);
    % 确保为正整数
    N_cs_integer = max(N_cs_integer, 1);
    % 计算对应的A_s
    A_s = (N_cs_integer / k)^(3/2);
D2L =P_rated / (C * A_s);
D_is=(D2L/X_length).^(1/3);
if Q<0
Q=max(round(pi*D_is/slot_pitch),2);
end
N_cs=round(a*(A_s*pi*D_is/I_ph/Q)); % 每槽导体数（默认每个槽容纳两条线圈边）
else
if Q<0
D2L=max(P_rated / C*pi*a*slot_pitch/N_cs/I_ph,P_rated/C/A_s_max);
D_is=(D2L/X_length).^(1/3);
Q=max(round(pi*D_is/slot_pitch),2);
end
N_cs =min(N_cs, ...
    round(pi * a * A_s_max^(2/3) * P_rated^(1/3) / (C^(1/3) * I_ph * Q * X_length^(1/3))));
DL =P_rated / C*pi*a/N_cs/I_ph/Q;
D_is=(DL/X_length).^.5;
A_s = N_cs*I_ph/a*Q/pi/D_is;
end
pmsm_input.N_cs=N_cs;
pmsm_input.A_s=A_s;
% L = (strcmpi(cooling,'liquid')*1.2 + 0.8) * D_is; % 铁芯长度(m)
L=X_length*D_is;
% D_os = D_is * (1.7 - 0.1*(strcmpi(pole_type,'IPM'))); % 定子外径(m)
D_os=D_is/X_stator;

%% 损耗与效率计算

    % 5-1. 槽满率验证
[~,A_wire] = mc_pmsm_calculate_wire_diameter(I_ph/a,J_max);
A_slot_min = N_cs*A_wire/slot_fill;% 需要的最小槽面积


if exist('A_s','var') && ~isa(A_s,'function_handle'), state.A_s=A_s; end
if exist('A_s_max','var') && ~isa(A_s_max,'function_handle'), state.A_s_max=A_s_max; end
if exist('A_slot_min','var') && ~isa(A_slot_min,'function_handle'), state.A_slot_min=A_slot_min; end
if exist('A_wire','var') && ~isa(A_wire,'function_handle'), state.A_wire=A_wire; end
if exist('C','var') && ~isa(C,'function_handle'), state.C=C; end
if exist('D2L','var') && ~isa(D2L,'function_handle'), state.D2L=D2L; end
if exist('DL','var') && ~isa(DL,'function_handle'), state.DL=DL; end
if exist('D_is','var') && ~isa(D_is,'function_handle'), state.D_is=D_is; end
if exist('D_os','var') && ~isa(D_os,'function_handle'), state.D_os=D_os; end
if exist('L','var') && ~isa(L,'function_handle'), state.L=L; end
if exist('N_cs','var') && ~isa(N_cs,'function_handle'), state.N_cs=N_cs; end
if exist('N_cs_initial','var') && ~isa(N_cs_initial,'function_handle'), state.N_cs_initial=N_cs_initial; end
if exist('N_cs_integer','var') && ~isa(N_cs_integer,'function_handle'), state.N_cs_integer=N_cs_integer; end
if exist('Q','var') && ~isa(Q,'function_handle'), state.Q=Q; end
if exist('k','var') && ~isa(k,'function_handle'), state.k=k; end
if exist('pmsm_input','var') && ~isa(pmsm_input,'function_handle'), state.pmsm_input=pmsm_input; end
if exist('sigma_max','var') && ~isa(sigma_max,'function_handle'), state.sigma_max=sigma_max; end
end
