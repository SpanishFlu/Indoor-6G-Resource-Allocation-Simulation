function plotResults(CFG, rr_stats, pf_stats, deadline_stats, kpi_table)
%PLOTRESULTS  Backlog timeline and KPI bar charts.

    t_axis = (0:CFG.n_slots-1) * CFG.slot_s;

    %% Backlog comparison
    figure('Name','Queue Backlog','Position',[50 50 800 350]);
    hold on;
    plot(t_axis, rr_stats.backlog_bits / 1e6,       'LineWidth',1.5,'DisplayName','RR');
    plot(t_axis, pf_stats.backlog_bits / 1e6,       'LineWidth',1.5,'DisplayName','PF');
    plot(t_axis, deadline_stats.backlog_bits / 1e6, 'LineWidth',1.5,'DisplayName','Deadline');
    title('Total Queue Backlog Over Time');
    xlabel('Time [s]'); ylabel('Backlog [Mbits]');
    ylim([0 8]);
    legend; grid on;
    hold off;

    %% KPI Dashboard
    schedulers  = {'RR','PF','Deadline'};
    served_mbps = kpi_table.served_Mbps';
    embb_succ   = kpi_table.embb_success';
    urllc_succ  = kpi_table.urllc_success';
    embb_delay  = kpi_table.embb_delay_mean_ms';
    urllc_delay = kpi_table.urllc_delay_mean_ms';

    figure('Name','KPI Dashboard','Position',[50 50 1200 380]);

    subplot(1,3,1);
    bar(served_mbps, 'FaceColor','flat', ...
        'CData', [0 0.45 0.74; 0.85 0.33 0.1; 0.47 0.67 0.19]);
    set(gca,'XTickLabel', schedulers);
    ylim([0 3.5]);
    title('Served Throughput'); ylabel('Mbps'); grid on;

    subplot(1,3,2);
    x_pos = 1:3;  w = 0.35;
    hold on;
    bar(x_pos - w/2, embb_succ,  w, 'DisplayName','eMBB');
    bar(x_pos + w/2, urllc_succ, w, 'DisplayName','URLLC');
    set(gca,'XTick',x_pos,'XTickLabel',schedulers);
    ylim([0 1.05]); title('Packet Success Rate'); legend; grid on;
    hold off;

    subplot(1,3,3);
    hold on;
    bar(x_pos - w/2, embb_delay,  w, 'DisplayName','eMBB');
    bar(x_pos + w/2, urllc_delay, w, 'DisplayName','URLLC');
    set(gca,'XTick',x_pos,'XTickLabel',schedulers);
    ylim([0 1200]);
    title('Mean Packet Delay'); ylabel('ms'); legend; grid on;
    hold off;

    sgtitle('KPI Dashboard - Indoor 6G Factory Simulation');
end
