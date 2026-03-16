function plotResults(CFG, rr_stats, pf_stats, deadline_stats, kpi_table)
%PLOTRESULTS Plot backlog comparison and KPI bar charts

    t = (0:CFG.n_slots-1) * CFG.slot_s;

    %% Plot C: backlog comparison
    figure('Name', 'Total backlog over time');
    hold on;
    plot(t, rr_stats.backlog_bits / 1e6, 'DisplayName', 'RR');
    plot(t, pf_stats.backlog_bits / 1e6, 'DisplayName', 'PF');
    plot(t, deadline_stats.backlog_bits / 1e6, 'DisplayName', 'Deadline');
    title('Total backlog over time');
    xlabel('time [s]');
    ylabel('backlog [Mbits]');
    grid on;
    legend('Location', 'best');
    hold off;

    %% Plot D: KPI bars
    figure('Name', 'KPIs');
    names = cellstr(kpi_table.scheduler);
    x = 1:numel(names);
    w = 0.35;

    % Served throughput
    subplot(1,3,1);
    bar(categorical(names), kpi_table.served_Mbps);
    title('Served throughput');
    ylabel('Mbps');
    grid on;

    % Packet success rate
    subplot(1,3,2);
    bar(x - w/2, kpi_table.embb_success, w, 'DisplayName', 'eMBB');
    hold on;
    bar(x + w/2, kpi_table.urllc_success, w, 'DisplayName', 'URLLC');
    hold off;
    xticks(x);
    xticklabels(names);
    ylim([0 1.05]);
    title('Packet success rate');
    grid on;
    legend('Location', 'best');

    % Mean packet delay
    subplot(1,3,3);
    bar(x - w/2, kpi_table.embb_delay_mean_ms, w, 'DisplayName', 'eMBB');
    hold on;
    bar(x + w/2, kpi_table.urllc_delay_mean_ms, w, 'DisplayName', 'URLLC');
    hold off;
    xticks(x);
    xticklabels(names);
    title('Mean packet delay');
    ylabel('ms');
    grid on;
    legend('Location', 'best');

end