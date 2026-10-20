function[DP]=RESHAPEMAP(DP)
%% 1、读取原始MAP
F=DP.F;
MAP0=DP.MAP;
nc=1;nt=1;
for k=1:length(DP.F)
if any(strcmpi(F(k), ["fan", "lpc", "hpc", "ipc"]))
MAP=MAP0.COMPRESSOR(nc);
elseif any(strcmpi(F(k), ["hpt", "lpt", "ipt"]))
MAP=MAP0.TURBINE(nt);
else
    continue
end
if isfield(MAP,"C_in")
C_in=MAP.C_in;
elseif isfield(MAP,"T_in")
C_in=MAP.T_in;
elseif isfield(MAP,"M_in")

end
maxeff=C_in.maxeff;
n_design=C_in.n_design;
NCOR=MAP.NCOR;
R=MAP.R;
WCOR=MAP.WCOR;
PR=MAP.PR;
EFF=MAP.EFF;
PR0=MAP.PR0;
WCOR0=MAP.WCOR0;
plotComponentMap(MAP,1)
%% 2、选择一个新的工作点
% 提示用户选择
title('Select A New Design Point');
disp('请在MAP图上选择一个设计点（支持重新选择）');

% 初始化变量
design_point = [];
selection_done = false;
point_handle = [];

while ~selection_done
    % 获取用户点击
    [x_selected, y_selected, button] = ginput(1);
    
    % 检查是否取消（右键、ESC键或关闭窗口）
    if isempty(x_selected) || button == 3
        fprintf('选择已取消\n');
        design_point = [];
        break;
    end
    
    % 删除之前的标记
    if ~isempty(point_handle) && isvalid(point_handle)
        delete(point_handle);
    end
    
    % 标记当前选择点
    hold on;
    point_handle = plot(x_selected, y_selected, 'ks', ...
        'MarkerSize', 12, 'MarkerFaceColor', 'y', 'LineWidth', 2);
    
    % 添加坐标标注
    hold off
    fprintf('当前选择点: (%.4f, %.4f)\n', x_selected, y_selected);
    
    % 询问是否确认
    choice = questdlg(...
        sprintf('设计点坐标: (%.4f, %.4f)\n\n确认选择此点吗？', ...
                x_selected, y_selected), ...
        '确认设计点', ...
        '确认', '重新选择', '取消', '确认');
    
    switch choice
        case '确认'
            design_point = [x_selected, y_selected];
            fprintf('设计点已确认: (%.4f, %.4f)\n', x_selected, y_selected);
            selection_done = true;
            
            % 更新标记为确认状态
            set(point_handle, ...
                'Marker', 'o', ...
                'MarkerFaceColor', 'g', ...
                'MarkerEdgeColor', 'k', ...
                'LineWidth', 2);
            
        case '重新选择'
            fprintf('请重新选择设计点...\n');
            % 继续循环，重新选择
            
        case '取消'
            fprintf('选择已取消\n');
            design_point = [];
            if ~isempty(point_handle) && isvalid(point_handle)
                delete(point_handle);
            end
            break;
    end
end
%% 3、新工作点定位
    % 计算所有网格点到选择点的距离
    if isfield(MAP,"C_in")
    distances = sqrt((WCOR - x_selected).^2 + (PR - y_selected).^2);
    elseif isfield(MAP,"T_in")
    distances = sqrt((NCOR.*WCOR - x_selected).^2 + (PR - y_selected).^2);
    end
    % 找到最小距离的索引
    [min_val, min_idx] = min(distances(:));
    
    % 将线性索引转换为行列索引
    [nx, ny] = ind2sub(size(WCOR), min_idx);
    
    % 输出结果
    fprintf('最近的数据点索引: [%d, %d]\n', nx, ny);
    fprintf('最近的数据点坐标: WCOR=%.4f, PR=%.4f\n', WCOR(nx, ny), PR(nx, ny));
    fprintf('与选择点的距离: %.6f\n', min_val);
close all
%% 4、更新MAP参数并绘制新的MAP
C_in.maxeff=nx;
C_in.n_design=ny;
if isfield(MAP,"C_in")
MAP.C_in=C_in;
elseif isfield(MAP,"T_in")
MAP.T_in=C_in;
elseif isfield(MAP,"M_in")

end
MAP.PR0=PR(nx,ny)*(PR0-1)+1;
MAP.PR=(PR*(PR0-1))./(PR(nx,ny)*(PR0-1));
MAP.NCOR=NCOR./NCOR(ny);
MAP.R=R./R(nx);
MAP.WCOR=WCOR./WCOR(nx,ny);
MAP.EFF=EFF./EFF(nx,ny);
plotComponentMap(MAP,1)
if any(strcmpi(F(k), ["fan", "lpc", "hpc", "ipc"]))
MAP0.COMPRESSOR(nc)=MAP;
nc=nc+1;
elseif any(strcmpi(F(k), ["hpt", "lpt", "ipt"]))
MAP0.TURBINE(nt)=MAP;
nt=nt+1;
end
end
DP.MAP=MAP0;
% end