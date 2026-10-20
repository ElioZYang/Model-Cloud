function DRAW_MAP_MISSION(MISSION)
    % Set global plotting defaults for consistency
    set(groot, 'DefaultAxesFontName', 'Arial');
    set(groot, 'DefaultAxesFontSize', 11);
    set(groot, 'DefaultTextFontName', 'Arial');
    set(groot, 'DefaultTextFontSize', 12);
    set(groot, 'DefaultLegendFontName', 'Arial');
    set(groot, 'DefaultLegendFontSize', 10);
    set(groot, 'DefaultLineLineWidth', 1.5);
    
    % Define color scheme
    colors = struct(...
        'contour', jet(256), ...
        'border', [0 0 0], ...
        'reference', [1, 0.2, 0.2], ...
        'operating', [1 1 0], ...
        'text', [0.2 0.2 0.2] ...
    );
    
    % Get data from mission structure
    
    DP = MISSION.G.DP;
    MAP = MISSION.G.DP.MAP;
    F = DP.F;
    NF = DP.NF;
    % Plot ducted fan
    if isfield(MISSION.G,'FAN_WP')&&~isempty(MISSION.G.FAN_WP)
    FAN_MAP=MISSION.G.MAP.COMPRESSOR(1);
    FAN_eff=MISSION.G.DP.EFFC(1);
    FAN_MAP.C_in.component="ducted fan";
    FAN_WP=MISSION.G.FAN_WP;
    plotComponentMap(FAN_MAP,FAN_eff,FAN_WP);
    end
    % Plot compressors and turbines
    nc = 0; nt = 0;
    for k = 1:NF
        if any(strcmpi(F(k), ["fan", "lpc", "hpc", "ipc"]))&&~isempty(MISSION.G.COMP_WP)
            nc = nc + 1;
            plotComponentMap(MAP.COMPRESSOR(nc), ...
                DP.EFFC(nc), ...
                MISSION.G.COMP_WP(2*nc-1:2*nc,:));
        elseif any(strcmpi(F(k), ["lpt", "hpt", "ipt"]))&&~isempty(MISSION.G.TURB_WP)
            nt = nt + 1;
            plotComponentMap(...
                MAP.TURBINE(nt), ...
                DP.EFFT(nt), ...
                MISSION.G.TURB_WP(2*nt-1:2*nt,:));
        end
    end
    
    % Plot motors
    for nm = 1:DP.NM
        if ~strcmpi(MAP.MOTOR(nm).M_in.basicmap, "NO")&&~isempty(MISSION.G.MOTOR_WP)
            plotMotorMap(...
                MAP.MOTOR(nm), ...
                DP.E_motor(nm), ...
                [MISSION.G.MOTOR_WP(2*nm-1,:); MISSION.G.MOTOR_WP(2*nm,:)]);
        else
            figure;
            scatter(MISSION.G.MOTOR_WP(2*nm-1,:),MISSION.G.MOTOR_WP(2*nm,:),"yellow","filled","square","MarkerEdgeColor","k")
            xlabel("Speed(normalized)")
            ylabel("Torque(normalized)")
            saveas(gcf,sprintf("pmsm %d mission.png",nm))
        end
    end
end
