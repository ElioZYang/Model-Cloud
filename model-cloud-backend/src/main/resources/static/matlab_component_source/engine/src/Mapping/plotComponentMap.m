function plotComponentMap(map,effScale,varargin)
if nargin==3
    wp=varargin{1};
end
    colors = struct(...
        'contour', jet(256), ...
        'border', [0 0 0], ...
        'reference', [1, 0.2, 0.2], ...
        'operating', [1 1 0], ...
        'text', [0.2 0.2 0.2] ...
    );
    if isfield(map,"C_in")
    xData = map.WCOR;
    yData = map.PR;
    xLabel = "$\bar{W}_{cor}$";       % \bar 用于单个字母/符号
    yLabel = "$\overline{\pi}_c$";    % \overline 用于多个字符
    effLabel = "\eta_c";      % 希腊字母同样适用
    basicmap=map.C_in.basicmap;
    component=map.C_in.component;
    elseif isfield(map,"T_in")
    xData = map.WCOR .* map.NCOR;
    yData = map.PR;
    xLabel = "$\bar{N}*\bar{W}_{cor}$";       % \bar 用于单个字母/符号
    yLabel = "$\overline{\pi}_t$";    % \overline 用于多个字符
    effLabel = "\eta_t";      % 希腊字母同样适用
    basicmap=map.T_in.basicmap;
    component=map.T_in.component;
    else
        error("check the component map input!")
    end

    % Create figure
    figure('Position', [100, 100, 800, 600], 'Color', 'w');
    
    % Prepare data
    effData = effScale * map.EFF;
    
    % Create contour plot
    [C, h] = contourf(xData, map.PR, effData, 20, 'LineStyle', 'none');
    colormap(colors.contour);
    cbar = colorbar;
    cbar.Label.String = effLabel;
%     cbar.Label.Interpreter = 'latex';
    cbar.Label.FontSize = 12;
    caxis([min(effData(:)), max(effData(:))]);
    
    % Add component characteristics
    hold on;
    plot(xData, yData, 'Color', colors.border, 'LineWidth', 1.5);
    
    % Add speed labels
    if isfield(map,"C_in")
        txl=1;
    else
        [txl,~]=size(map.PR);
    end
    text(...
        xData(txl,:), map.PR(txl,:), string(map.NCOR), ...
        'Color', colors.text, ...
        'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'right', ...
        'FontSize', 9 ...
    );
    
    % Add reference and operating points
    scatter(1, 1, 200, colors.reference, 'pentagram', 'filled', ...
       'MarkerEdgeColor', colors.border,'LineWidth', 1);
    filename=component+" map";
    if nargin==3
    scatter(wp(1,:), wp(2,:), 60, colors.operating, 'square', 'filled', ...
           'MarkerEdgeColor', colors.border, 'LineWidth', 0.5);
    filename=component+" map mission";
    end
    
    % Format axes
    title(basicmap, 'FontWeight', 'normal');
    xlabel(xLabel, 'Interpreter', 'latex');
    ylabel(yLabel, 'Interpreter', 'latex');
    grid on;
    axis tight;
    box on;
    
    % Save figure
    exportgraphics(gcf, strcat(filename,'.png'), 'Resolution', 300);
%     close(gcf);
end
