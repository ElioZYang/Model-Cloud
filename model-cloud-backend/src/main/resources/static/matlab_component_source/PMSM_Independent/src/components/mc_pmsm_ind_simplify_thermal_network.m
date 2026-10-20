function [A, B] = mc_pmsm_ind_simplify_thermal_network(R, C, P, LM1, LM2)
% 简化热阻网络并构建动态系统 dT/dt = A*T + B
%
% 输入参数：
%   R_values: 热阻值矩阵 (N x N)，R(i,j)表示i,j节点间的热阻
%   N1: 要合并的节点数
%   N2: 关键温度节点数
%   C: 热容向量 (N2+1 x 1)
%   P: 功率输入向量 (N2+1 x 1)
%   LM1: 合并节点的位置编号向量 (N1 x 1)
%   LM2: 关键节点的位置编号向量 (N2 x 1)
    N = size(R, 1);
    N1=length(LM1);
    N2=length(LM2);

    
    %% 第一步：从热阻值构建正确的热导矩阵（向量化）
    mask = ~eye(N);
%     valid_resistance = mask & (R > 0);
%     G_off_diag = -1 ./ R .* valid_resistance;
    G_off_diag = -1 ./ R;
%     G_off_diag(~valid_resistance) = 0;
    G0 = G_off_diag;
    G0(1:N+1:end) = -sum(G_off_diag, 2);
    
    %% 第二步：节点聚合（使用LM1指定的节点）
    % 确定剩余节点（不在LM1中的节点）
    all_nodes = 1:N;
    remaining_nodes = setdiff(all_nodes, LM1);
    
    % 重新排列节点：剩余节点在前，聚合节点在后
    idx_T = remaining_nodes;      % 独立节点
    idx_S = LM1;                  % 要聚合的节点
    
    % 提取分块矩阵
    G_TT = G0(idx_T, idx_T);
    G_TS = G0(idx_T, idx_S);
    G_SS = G0(idx_S, idx_S);
    
    J = ones(N1, 1);
    
    % 计算聚合后的热导矩阵
    K = length(remaining_nodes);
    G1 = zeros(K+1, K+1);
    G1(1:K, 1:K) = G_TT;
    G_T_new = G_TS * J;
    G1(1:K, K+1) = G_T_new;
    G1(K+1, 1:K) = G_T_new';
    G1(K+1, K+1) = J' * G_SS * J;
    
    % 创建节点映射：新节点索引 -> 原节点索引
    % 新节点顺序: [remaining_nodes, 聚合节点]
    
    %% 第三步：舒尔补简化（选择LM2指定的关键节点）
    total_nodes = size(G1, 1);
    
    % 找到LM2节点在G1中的位置
    LM2_positions = zeros(1, N2);
    for i = 1:N2
        % 在remaining_nodes中查找LM2(i)的位置
        pos = find(remaining_nodes == LM2(i), 1);
        if isempty(pos)
            error('关键节点 %d 不在剩余节点中', LM2(i));
        end
        LM2_positions(i) = pos;
    end
    
    % 关心的节点：LM2节点 + 聚合节点
    idx_C = [LM2_positions, total_nodes];  % LM2位置 + 聚合节点位置
    idx_U = setdiff(1:total_nodes, idx_C);
    
    % 提取分块矩阵
    G_CC = G1(idx_C, idx_C);
    G_CU = G1(idx_C, idx_U);
    G_UC = G1(idx_U, idx_C);
    G_UU = G1(idx_U, idx_U);
    
    % 舒尔补计算
    G_simplified = G_CC - G_CU * (G_UU \ G_UC);
    G_simplified = (G_simplified + G_simplified') / 2;
    
    %% 第四步：重新排序节点为 [合并节点, LM2(1), LM2(2), ..., LM2(N1)]
    % 当前G_simplified的顺序是 [LM2(1), LM2(2), ..., LM2(N1), 合并节点]
    % 需要重新排列为 [合并节点, LM2(1), LM2(2), ..., LM2(N1)]
    
    % 创建重排索引
    reorder_idx = [N2+1, 1:N2];  % 将最后一个节点（聚合节点）移到第一个位置
    
    % 重排热导矩阵
    G_final = G_simplified(reorder_idx, reorder_idx);
    
    % 重排热容向量（假设输入C的顺序与G_simplified原顺序一致）
%     C_reordered = C(reorder_idx);
    C_reordered=C;    
    % 重排功率向量（假设输入P的顺序与G_simplified原顺序一致）
%     P_reordered = P(reorder_idx);
    P_reordered=P;
    %% 第五步：构建动态系统
    C_diag = diag(C_reordered);
    if det(C_diag)<1E-9
        warning("thermal network invalid")
        disp("Resistance Network")
        disp(R)
        disp("Heat Capacity Network")
        disp(C_diag)
    end
    A = -C_diag \ G_final;
    B = C_diag \ P_reordered;
end
