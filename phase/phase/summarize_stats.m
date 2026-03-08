function summary = summarize_stats(stats, cfg)

total_arr_bits = stats.arrived_bits.embb + stats.arrived_bits.urllc;
total_srv_bits = stats.served_bits.embb + stats.served_bits.urllc;

offered_rate = total_arr_bits / cfg.sim_time_s;
served_rate  = total_srv_bits / cfg.sim_time_s;

summary.scheduler = stats.scheduler;
summary.offered_Mbps = offered_rate / 1e6;
summary.served_Mbps = served_rate / 1e6;
summary.load_ratio_offered_over_served = offered_rate / max(served_rate, cfg.eps);
summary.embb_success = stats.delivered.embb / max(stats.arrivals.embb, 1);
summary.urllc_success = stats.delivered.urllc / max(stats.arrivals.urllc, 1);
summary.embb_delay_mean_ms = 1e3 * safe_mean(stats.delays_s.embb);
summary.urllc_delay_mean_ms = 1e3 * safe_mean(stats.delays_s.urllc);
summary.embb_delay_p95_ms = 1e3 * safe_p95(stats.delays_s.embb);
summary.urllc_delay_p95_ms = 1e3 * safe_p95(stats.delays_s.urllc);

end