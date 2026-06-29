function summary=summarize_stats(stats,cfg)
% SUMMARIZE_STATS  KPI summary including Jain Fairness and RB Utilization.
    arr=stats.arrived_bits_embb+stats.arrived_bits_urllc;
    srv=stats.served_bits_embb +stats.served_bits_urllc;
    off_r=arr/cfg.sim_time_s; srv_r=srv/cfg.sim_time_s;

    summary.scheduler   =stats.scheduler;
    summary.offered_Mbps=off_r/1e6;
    summary.served_Mbps =srv_r/1e6;
    summary.load_ratio  =off_r/max(srv_r,cfg.eps);

    summary.embb_success =stats.delivered_embb /max(stats.arrivals_embb,1);
    summary.urllc_success=stats.delivered_urllc/max(stats.arrivals_urllc,1);

    summary.embb_delay_mean_ms =1e3*safe_mean(stats.delays_s_embb);
    summary.urllc_delay_mean_ms=1e3*safe_mean(stats.delays_s_urllc);
    summary.embb_delay_p95_ms  =1e3*safe_p95(stats.delays_s_embb);
    summary.urllc_delay_p95_ms =1e3*safe_p95(stats.delays_s_urllc);

    % Jain Fairness Index
    x=stats.served_user_bits; n=length(x);
    if n>0&&sum(x)>0
        summary.jain_fairness=(sum(x))^2/(n*sum(x.^2)+cfg.eps);
    else; summary.jain_fairness=NaN; end

    % RB Utilization (mean over slots)
    summary.rb_utilization=mean(stats.rb_utilization);
end
