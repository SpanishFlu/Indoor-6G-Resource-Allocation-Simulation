function plot_results(cfg, trace, rr_stats, pf_stats, deadline_stats, ...
                       summary_rr, summary_pf, summary_deadline)
% PLOT_RESULTS  Generate all simulation result figures.
%   plot_results(cfg, trace, rr_stats, pf_stats, deadline_stats, ...
%                summary_rr, summary_pf, summary_deadline)

    % ---- Plot A: Factory layout and robot trajectories ----
    figure('Name', 'Factory Layout');
    hold on;
    plot([0, cfg.factory_w_m, cfg.factory_w_m, 0, 0], ...
         [0, 0, cfg.factory_h_m, cfg.factory_h_m, 0], 'k-', 'LineWidth', 1.5);

    bs = cfg.bs_xy_m;
    scatter(bs(:,1), bs(:,2), 120, 'r', '^', 'filled', 'DisplayName', 'BS');

    colors = lines(cfg.n_robots);
    for u = 1:cfg.n_robots
        xy = squeeze(trace.pos(:, u, :));  % (T, 2)
        plot(xy(:,1), xy(:,2), 'LineWidth', 1.5, 'Color', colors(u,:), ...
             'DisplayName', sprintf('Robot %d', u));
        scatter(xy(1,1), xy(1,2), 30, colors(u,:), 'filled', ...
                'HandleVisibility', 'off');
    end

    title('Factory layout and robot lane trajectories');
    xlabel('x [m]');
    ylabel('y [m]');
    axis equal;
    grid on;
    alpha(0.3);
    legend('Location', 'northoutside', 'Orientation', 'horizontal');
    hold off;

    % ---- Plot B: Distance evolution from selected BS ----
    bs_idx = min(max(cfg.distance_plot_bs_index, 1), cfg.n_bs);
    t_vec = (0:cfg.n_slots-1) * cfg.slot_s;

    figure('Name', 'Distance Evolution');
    hold on;
    for u = 1:cfg.n_robots
        plot(t_vec, squeeze(trace.d2d(:, bs_idx, u)), ...
             'DisplayName', sprintf('BS%d-Robot%d', bs_idx, u));
    end
    title(sprintf('Distance evolution (BS%d to robots)', bs_idx));
    xlabel('time [s]');
    ylabel('distance [m]');
    grid on;
    legend();
    hold off;

    % ---- Plot C: Backlog comparison ----
    figure('Name', 'Backlog');
    hold on;
    plot(t_vec, rr_stats.backlog_bits / 1e6, 'DisplayName', 'RR');
    plot(t_vec, pf_stats.backlog_bits / 1e6, 'DisplayName', 'PF');
    plot(t_vec, deadline_stats.backlog_bits / 1e6, 'DisplayName', 'Deadline');
    title('Total backlog over time');
    xlabel('time [s]');
    ylabel('backlog [Mbits]');
    grid on;
    legend();
    hold off;

    % ---- Plot D: KPI bar charts ----
    names = {summary_rr.scheduler, summary_pf.scheduler, summary_deadline.scheduler};
    served = [summary_rr.served_Mbps, summary_pf.served_Mbps, summary_deadline.served_Mbps];
    embb_succ  = [summary_rr.embb_success,  summary_pf.embb_success,  summary_deadline.embb_success];
    urllc_succ = [summary_rr.urllc_success, summary_pf.urllc_success, summary_deadline.urllc_success];
    embb_delay  = [summary_rr.embb_delay_mean_ms,  summary_pf.embb_delay_mean_ms,  summary_deadline.embb_delay_mean_ms];
    urllc_delay = [summary_rr.urllc_delay_mean_ms, summary_pf.urllc_delay_mean_ms, summary_deadline.urllc_delay_mean_ms];

    figure('Name', 'KPI Comparison', 'Position', [100, 100, 1100, 350]);

    subplot(1, 3, 1);
    bar(categorical(names), served);
    title('Served throughput');
    ylabel('Mbps');
    grid on;

    subplot(1, 3, 2);
    x = 1:3;
    w = 0.35;
    bar(x - w/2, embb_succ, w, 'DisplayName', 'eMBB'); hold on;
    bar(x + w/2, urllc_succ, w, 'DisplayName', 'URLLC');
    set(gca, 'XTick', x, 'XTickLabel', names);
    ylim([0, 1.05]);
    title('Packet success rate');
    grid on;
    legend();
    hold off;

    subplot(1, 3, 3);
    bar(x - w/2, embb_delay, w, 'DisplayName', 'eMBB'); hold on;
    bar(x + w/2, urllc_delay, w, 'DisplayName', 'URLLC');
    set(gca, 'XTick', x, 'XTickLabel', names);
    title('Mean packet delay');
    ylabel('ms');
    grid on;
    legend();
    hold off;
end
