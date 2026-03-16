function plotDistances(CFG, trace)
%PLOTDISTANCES Plot distance evolution from selected BS to all robots

    bs_idx = min(max(CFG.distance_plot_bs_index, 1), CFG.n_bs);
    t = (0:CFG.n_slots-1) * CFG.slot_s;

    figure('Name', 'Distance evolution');

    hold on;
    for u = 1:CFG.n_robots
        plot(t, squeeze(trace.d2d(:, bs_idx, u)), ...
            'DisplayName', sprintf('BS%d-Robot%d', bs_idx-1, u-1));
    end

    title(sprintf('Distance evolution (BS%d to robots)', bs_idx-1));
    xlabel('time [s]');
    ylabel('distance [m]');
    grid on;
    legend('Location', 'best');
    hold off;

end