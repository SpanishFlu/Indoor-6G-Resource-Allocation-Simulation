function plotFactory(CFG, trace)
%PLOTFACTORY  Factory layout with robot trajectories.
    figure('Name','Factory Layout','Position',[50 50 800 480]);
    hold on;
    rectangle('Position',[0 0 CFG.factory_w_m CFG.factory_h_m], ...
              'EdgeColor','k','LineWidth',1.5);

    bs = CFG.bs_xy_m;
    scatter(bs(:,1), bs(:,2), 150, 'r', '^', 'filled', 'DisplayName','BS');

    clrs = lines(CFG.n_robots);
    for u = 1:CFG.n_robots
        xy = squeeze(trace.pos(:, u, :));
        plot(xy(:,1), xy(:,2), 'Color', clrs(u,:), 'LineWidth', 1.5, ...
             'DisplayName', sprintf('Robot %d', u));
        scatter(xy(1,1), xy(1,2), 30, clrs(u,:), 'filled', 'HandleVisibility','off');
    end

    axis equal;
    xlim([-1, CFG.factory_w_m+1]);
    ylim([-1, CFG.factory_h_m+1]);
    title('Factory Layout and Robot Lane Trajectories');
    xlabel('x [m]'); ylabel('y [m]');
    legend('Location','northoutside','NumColumns',4);
    grid on; grid minor;
    hold off;
end
