function summary = summarizeResults(stats, CFG)
%SUMMARIZERESULTS  Compute KPI summary from raw simulation stats.
    total_arr = stats.arrived_bits.embb + stats.arrived_bits.urllc;
    total_srv = stats.served_bits.embb  + stats.served_bits.urllc;

    offered_rate = total_arr / CFG.sim_time_s;
    served_rate  = total_srv / CFG.sim_time_s;

    summary.scheduler           = stats.scheduler;
    summary.offered_Mbps        = offered_rate / 1e6;
    summary.served_Mbps         = served_rate  / 1e6;
    summary.load_ratio          = offered_rate / max(served_rate, CFG.eps);
    summary.embb_success        = stats.delivered.embb  / max(stats.arrivals.embb,  1);
    summary.urllc_success       = stats.delivered.urllc / max(stats.arrivals.urllc, 1);
    summary.embb_delay_mean_ms  = 1e3 * safeMean(stats.delays_s.embb);
    summary.urllc_delay_mean_ms = 1e3 * safeMean(stats.delays_s.urllc);
    summary.embb_delay_p95_ms   = 1e3 * safeP95(stats.delays_s.embb);
    summary.urllc_delay_p95_ms  = 1e3 * safeP95(stats.delays_s.urllc);
end

function m = safeMean(x)
    if isempty(x), m = NaN; else, m = mean(x); end
end

function p = safeP95(x)
    if isempty(x), p = NaN; else, p = prctile(x, 95); end
end
