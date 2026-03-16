function kpi = summarizeResults(stats, CFG)
%SUMMARIZERESULTS Convert simulation stats into KPI struct

    total_arr_bits = stats.arrived_bits.embb + stats.arrived_bits.urllc;
    total_srv_bits = stats.served_bits.embb + stats.served_bits.urllc;

    offered_rate = total_arr_bits / CFG.sim_time_s;
    served_rate = total_srv_bits / CFG.sim_time_s;

    kpi = struct();
    kpi.scheduler = stats.scheduler;
    kpi.offered_Mbps = offered_rate / 1e6;
    kpi.served_Mbps = served_rate / 1e6;
    kpi.load_ratio_offered_over_served = offered_rate / max(served_rate, CFG.eps);

    kpi.embb_success = stats.delivered.embb / max(stats.arrivals.embb, 1);
    kpi.urllc_success = stats.delivered.urllc / max(stats.arrivals.urllc, 1);

    kpi.embb_delay_mean_ms = 1e3 * safeMean(stats.delays_s.embb);
    kpi.urllc_delay_mean_ms = 1e3 * safeMean(stats.delays_s.urllc);

    kpi.embb_delay_p95_ms = 1e3 * safeP95(stats.delays_s.embb);
    kpi.urllc_delay_p95_ms = 1e3 * safeP95(stats.delays_s.urllc);

end

function y = safeMean(x)
% return NaN when empty

    if isempty(x)
        y = NaN;
    else
        y = mean(x);
    end
end

function y = safeP95(x)
% return NaN when empty

    if isempty(x)
        y = NaN;
    else
        y = prctile(x, 95);
    end
end