function plotFactory(CFG, trace)
%PLOTFACTORY Plot factory layout and robot lane trajectories

    figure('Name', 'Factory layout and robot lane trajectories');

    hold on;
    box on;

    % Factory boundary
    plot([0, CFG.factory_w_m, CFG.factory_w_m, 0, 0], ...
         [0, 0, CFG.factory_h_m, CFG.factory_h_m, 0], 'k-');

    % Base stations
    bs = CFG.bs_xy_m;
    scatter(bs(:,1), bs(:,2), 120, 'r', '^', 'filled', 'DisplayName', 'BS');

    % Robot trajectories
    for u = 1:CFG.n_robots
        xy = squeeze(trace.pos(:, u, :));   % [T x 2]
        plot(xy(:,1), xy(:,2), 'LineWidth', 1.5, 'DisplayName', sprintf('Robot %d', u-1));
        scatter(xy(1,1), xy(1,2), 30, 'filled', 'HandleVisibility', 'off');
    end

    title('Factory layout and robot lane trajectories');
    xlabel('x [m]');
    ylabel('y [m]');
    axis equal;
    grid on;
    legend('Location', 'northoutside', 'NumColumns', 3);
    hold off;

end