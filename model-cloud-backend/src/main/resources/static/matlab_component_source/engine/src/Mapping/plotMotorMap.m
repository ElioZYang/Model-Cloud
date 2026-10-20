function plotMotorMap(map,effScale,varargin)
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
    basicmap=map.M_in.basicmap;
    component=map.M_in.component;
    NCOR=map.NCOR;WCOR=map.TORQUE_mech;
    % Create figure
    figure('Position', [100, 100, 800, 600], 'Color', 'w');
    
    % Prepare data
    NRPM1 = repmat(NCOR, length(WCOR), 1);
    effData = effScale * map.EFFM;
    
    % Create contour plot
    [C, h] = contourf(NRPM1, WCOR, effData, 20, 'LineStyle', 'none');
    colormap(colors.contour);
    cbar = colorbar;
    cbar.Label.String = '\eta_m';
    cbar.Label.FontSize = 12;
    caxis([min(effData(:)), max(effData(:))]);
    
    % Add motor characteristics
    hold on;
    plot(NCOR, WCOR(1), 'Color', colors.border, 'LineWidth', 1.5);
    plot(NCOR, WCOR(end), 'Color', colors.border, 'LineWidth', 1.5);
    
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
    xlabel("$\bar{N}$", 'Interpreter', 'latex');
    ylabel("$\bar{Torque}$", 'Interpreter', 'latex');
    grid on;
    axis tight;
    box on;
    
    % Save figure
    exportgraphics(gcf, strcat(filename,'.png'), 'Resolution', 300);
    close(gcf);
end