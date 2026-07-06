function plot_pf_before_after(summary_before, summary_a, summary_b, bw_before_Hz, bw_a_Hz, bw_b_Hz)
% PLOT_PF_BEFORE_AFTER  Visual comparison of PF scheduler KPIs: before
% (flat bandwidth) vs Method A (Shannon, class-derived effective
% bandwidth) vs Method B (RB-based, per-service fixed MCS).
%   plot_pf_before_after(summary_before, summary_a, summary_b, ...
%                         bw_before_Hz, bw_a_Hz, bw_b_Hz)

    figure('Name', 'PF: Before vs Method A vs Method B', ...
           'Position', [100, 100, 1300, 700]);

    labels = {'Before', 'Method A', 'Method B'};
    xc = categorical(labels);
    xc = reordercats(xc, labels);

    % ---- Panel 1: mean effective bandwidth ----
    subplot(2, 3, 1);
    bar(xc, [bw_before_Hz, bw_a_Hz, bw_b_Hz] / 1e6);
    title('Mean effective bandwidth');
    ylabel('MHz');
    grid on;

    % ---- Panel 2: served throughput ----
    subplot(2, 3, 2);
    bar(xc, [summary_before.served_Mbps, summary_a.served_Mbps, summary_b.served_Mbps]);
    title('PF served throughput');
    ylabel('Mbps');
    grid on;

    % ---- Panel 3: load ratio ----
    subplot(2, 3, 3);
    bar(xc, [summary_before.load_ratio, summary_a.load_ratio, summary_b.load_ratio]);
    title('Load ratio (offered / served)');
    ylabel('Ratio');
    grid on;

    % ---- Panel 4: success rate per class ----
    subplot(2, 3, 4);
    x = 1:3;
    w = 0.35;
    embb_succ  = [summary_before.embb_success,  summary_a.embb_success,  summary_b.embb_success];
    urllc_succ = [summary_before.urllc_success, summary_a.urllc_success, summary_b.urllc_success];
    bar(x - w/2, embb_succ, w, 'DisplayName', 'eMBB'); hold on;
    bar(x + w/2, urllc_succ, w, 'DisplayName', 'URLLC');
    set(gca, 'XTick', x, 'XTickLabel', labels);
    ylim([0, 1.05]);
    title('Packet success rate');
    grid on;
    legend('Location', 'best');
    hold off;

    % ---- Panel 5: mean delay per class ----
    subplot(2, 3, 5);
    embb_delay  = [summary_before.embb_delay_mean_ms,  summary_a.embb_delay_mean_ms,  summary_b.embb_delay_mean_ms];
    urllc_delay = [summary_before.urllc_delay_mean_ms, summary_a.urllc_delay_mean_ms, summary_b.urllc_delay_mean_ms];
    bar(x - w/2, embb_delay, w, 'DisplayName', 'eMBB'); hold on;
    bar(x + w/2, urllc_delay, w, 'DisplayName', 'URLLC');
    set(gca, 'XTick', x, 'XTickLabel', labels);
    ylabel('ms');
    title('Mean delay');
    grid on;
    legend('Location', 'best');
    hold off;

    % ---- Panel 6: p95 delay per class ----
    subplot(2, 3, 6);
    embb_p95  = [summary_before.embb_delay_p95_ms,  summary_a.embb_delay_p95_ms,  summary_b.embb_delay_p95_ms];
    urllc_p95 = [summary_before.urllc_delay_p95_ms, summary_a.urllc_delay_p95_ms, summary_b.urllc_delay_p95_ms];
    bar(x - w/2, embb_p95, w, 'DisplayName', 'eMBB'); hold on;
    bar(x + w/2, urllc_p95, w, 'DisplayName', 'URLLC');
    set(gca, 'XTick', x, 'XTickLabel', labels);
    ylabel('ms');
    title('p95 delay');
    grid on;
    legend('Location', 'best');
    hold off;
end
