function summary = summarize_stats(stats, cfg)
% SUMMARIZE_STATS  Compute final KPI summary from simulation stats.
%   summary = summarize_stats(stats, cfg)

    total_arr_bits = stats.arrived_bits_embb + stats.arrived_bits_urllc;
    total_srv_bits = stats.served_bits_embb  + stats.served_bits_urllc;

    offered_rate = total_arr_bits / cfg.sim_time_s;
    served_rate  = total_srv_bits / cfg.sim_time_s;

    summary.scheduler    = stats.scheduler;
    summary.offered_Mbps = offered_rate / 1e6;
    summary.served_Mbps  = served_rate / 1e6;
    summary.load_ratio   = offered_rate / max(served_rate, cfg.eps);

    summary.embb_success  = stats.delivered_embb  / max(stats.arrivals_embb,  1);
    summary.urllc_success = stats.delivered_urllc / max(stats.arrivals_urllc, 1);

    summary.embb_delay_mean_ms  = 1e3 * safe_mean(stats.delays_s_embb);
    summary.urllc_delay_mean_ms = 1e3 * safe_mean(stats.delays_s_urllc);
    summary.embb_delay_p95_ms   = 1e3 * safe_p95(stats.delays_s_embb);
    summary.urllc_delay_p95_ms  = 1e3 * safe_p95(stats.delays_s_urllc);
end
