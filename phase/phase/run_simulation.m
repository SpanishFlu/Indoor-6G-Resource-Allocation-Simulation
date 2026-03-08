function stats = run_simulation(cfg, trace, scheduler_name)

T = cfg.n_slots;
B = cfg.n_bs;
U = cfg.n_robots;

% initialize queues
queues = init_queues(U);

% round-robin pointer
rr_ptr = 1:B;

% initial PF user average rate
avg_user_rate = 1e3 * ones(1,U);

% initialize statistics struct
stats.scheduler = scheduler_name;

stats.arrivals.embb = 0;
stats.arrivals.urllc = 0;
stats.arrived_bits.embb = 0;
stats.arrived_bits.urllc = 0;
stats.delivered.embb = 0;
stats.delivered.urllc = 0;
stats.drops.embb = 0;
stats.drops.urllc = 0;
stats.delays_s.embb = [];
stats.delays_s.urllc = [];
stats.served_bits.embb = 0;
stats.served_bits.urllc = 0;
stats.served_user_bits = zeros(1,U);
stats.scheduled_users = -ones(T,B);
stats.backlog_bits = zeros(T,1);

% convert powers to Watts
tx_power_W = dBm_to_W(cfg.tx_power_dBm);
noise_W = dBm_to_W(trace.noise_dBm);

% ----------------------------
% simulation loop over slots
% ----------------------------
for t = 1:T
    
    % arrivals and deadline drops
    [queues, stats] = add_arrivals_to_queues(queues, trace.arrivals, t, cfg, stats);
    [queues, stats] = drop_expired_packets(queues, t, stats);
    
    % backlog per user
    backlog_per_user = queue_backlog_bits(queues);
    has_backlog = backlog_per_user > 0;
    
    % schedule per BS
    switch scheduler_name
        case 'rr'
            [selected, rr_ptr] = schedule_rr(has_backlog, rr_ptr, B);
        case 'pf'
            selected = schedule_pf(has_backlog, squeeze(trace.rate_no_int_bps(t,:,:)), avg_user_rate, B);
        case 'deadline'
            deadline_left = earliest_deadline_remaining_slots(queues, t);
            selected = schedule_deadline(has_backlog, deadline_left, squeeze(trace.rate_no_int_bps(t,:,:)), B);
        otherwise
            error("scheduler_name must be 'rr', 'pf', or 'deadline'");
    end
    
    stats.scheduled_users(t,:) = selected;
    
    inst_user_rate = zeros(1,U);
    
    % ----------------------------
    % transmit on each BS
    % ----------------------------
    for b = 1:B
        u = selected(b);
        if u < 0
            continue;
        end
        
        % desired signal
        pl_bu_dB = trace.pl_dB(t,b,u);
        signal_W = tx_power_W * 10^(-pl_bu_dB/10);
        
        % interference from other active BS
        interf_W = 0;
        for b2 = 1:B
            if b2 == b
                continue;
            end
            u2 = selected(b2);
            if u2 < 0
                continue;
            end
            pl_b2u_dB = trace.pl_dB(t,b2,u);
            interf_W = interf_W + tx_power_W * 10^(-pl_b2u_dB/10);
        end
        
        sinr = signal_W / (noise_W + interf_W + cfg.eps);
        rate_bps = cfg.bandwidth_Hz * log2(1 + sinr);
        bit_budget = rate_bps * cfg.slot_s;
        
        [queues, served, stats] = serve_user_packets(queues, u, bit_budget, t, cfg, stats);
        
        served_u = served.embb + served.urllc;
        
        stats.served_bits.embb = stats.served_bits.embb + served.embb;
        stats.served_bits.urllc = stats.served_bits.urllc + served.urllc;
        stats.served_user_bits(u) = stats.served_user_bits(u) + served_u;
        inst_user_rate(u) = inst_user_rate(u) + served_u / cfg.slot_s;
    end
    
    % PF moving-average update
    avg_user_rate = cfg.pf_alpha * avg_user_rate + (1 - cfg.pf_alpha) * inst_user_rate;
    
    stats.backlog_bits(t) = sum(queue_backlog_bits(queues));
    
end

end