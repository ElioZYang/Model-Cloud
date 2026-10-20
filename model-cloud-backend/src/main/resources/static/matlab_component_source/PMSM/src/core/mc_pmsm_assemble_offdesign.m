function state = mc_pmsm_assemble_offdesign(state)
% Generated from the engine reference; see provenance.json.
if isfield(state,'I_ph_offdesign'), I_ph_offdesign=state.I_ph_offdesign; end
if isfield(state,'P_cu'), P_cu=state.P_cu; end
if isfield(state,'P_fe'), P_fe=state.P_fe; end
if isfield(state,'P_loss'), P_loss=state.P_loss; end
if isfield(state,'P_mag'), P_mag=state.P_mag; end
if isfield(state,'P_mech'), P_mech=state.P_mech; end
if isfield(state,'P_offdesign'), P_offdesign=state.P_offdesign; end
if isfield(state,'P_stray'), P_stray=state.P_stray; end
if isfield(state,'P_windage'), P_windage=state.P_windage; end
if isfield(state,'V_ph_offdesign'), V_ph_offdesign=state.V_ph_offdesign; end
if isfield(state,'cal_mode'), cal_mode=state.cal_mode; end
if isfield(state,'eta'), eta=state.eta; end
if isfield(state,'fieldNames'), fieldNames=state.fieldNames; end
if isfield(state,'fn'), fn=state.fn; end
if isfield(state,'losses_offdesign'), losses_offdesign=state.losses_offdesign; end
if isfield(state,'n_offdesign'), n_offdesign=state.n_offdesign; end
if isfield(state,'performance_offdesign'), performance_offdesign=state.performance_offdesign; end
if isfield(state,'pmsm_params_offdesign'), pmsm_params_offdesign=state.pmsm_params_offdesign; end
if isfield(state,'winding'), winding=state.winding; end
%% 更新输出结构体的非设计点参数
% 性能参数更新
performance_offdesign = struct(...
    'speed', n_offdesign, ...
    'power', cal_mode*P_offdesign, ...
    'mechanical_power', cal_mode*P_mech, ......
    'efficiency', eta, ...
    'voltage', V_ph_offdesign, ...
    'current', I_ph_offdesign, ...
    'current_density', I_ph_offdesign/(pi*(winding.wire_dia/2000)^2)/1e6);    

fieldNames = fieldnames(performance_offdesign);
for fn = fieldNames'
    pmsm_params_offdesign.performance.(fn{1}) = performance_offdesign.(fn{1});
end

% 损耗参数更新
losses_offdesign = struct(...
    'copper', P_cu, ...
    'iron', P_fe, ...
    'magnet', P_mag,...
    'windage', P_windage, ...
    'bearing', pmsm_params_offdesign.losses.bearing, ... % 轴承损耗不变
    'stray', P_stray, ...
    'total', P_loss);

fieldNames = fieldnames(losses_offdesign);
for fn = fieldNames'
    pmsm_params_offdesign.losses.(fn{1}) = losses_offdesign.(fn{1});
end

% fprintf('\n=== 非设计点计算结果 ===\n');
% fprintf('转速: %.1f rpm, 电功率: %.1f kW, 效率: %.2f%%\n', ...
%     n_offdesign, P_offdesign/1000, eta*100);
% fprintf('最终效率: %.2f%%, 总损耗: %.1fW (铜耗: %.1fW, 铁耗: %.1fW, 磁损: %.1fW)\n',...
%     eta*100, P_loss, P_cu, P_fe, P_mag);
if exist('fieldNames','var') && ~isa(fieldNames,'function_handle'), state.fieldNames=fieldNames; end
if exist('fn','var') && ~isa(fn,'function_handle'), state.fn=fn; end
if exist('losses_offdesign','var') && ~isa(losses_offdesign,'function_handle'), state.losses_offdesign=losses_offdesign; end
if exist('performance_offdesign','var') && ~isa(performance_offdesign,'function_handle'), state.performance_offdesign=performance_offdesign; end
if exist('pmsm_params_offdesign','var') && ~isa(pmsm_params_offdesign,'function_handle'), state.pmsm_params_offdesign=pmsm_params_offdesign; end
end
