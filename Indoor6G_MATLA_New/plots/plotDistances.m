function plotDistances(CFG, trace)
%PLOTDISTANCES  Distance evolution from BS 1 to all robots.
    t_axis = (0:CFG.n_slots-1) * CFG.slot_s;

    figure('Name','Distance Evolution','Position',[50 50 800 350]);
    hold on;
    for u = 1:CFG.n_robots
        plot(t_axis, trace.d2d(:, 1, u), 'LineWidth', 1.5, ...
             'DisplayName', sprintf('BS1-Robot%d', u));
    end
    title('Distance Evolution (BS1 to Robots)');
    xlabel('Time [s]'); ylabel('Distance [m]');
    legend; grid on;
    hold off;
end
