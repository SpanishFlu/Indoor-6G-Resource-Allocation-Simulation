function stats = runSimulation(CFG, trace, scheduler_name)
%RUNSIMULATION  Execute the full time-domain simulation for one scheduler.
%   FIX: rr_ptr initialised to 0-based [0, 1, ...] to match Python.

    T = CFG.n_slots;
    B = CFG.n_bs;
    U = CFG.n_robots;

    queues = initQueues(U);
    rr_ptr = 0:(B-1);                              % 0-based (Python match)
    avg_user_rate = 1e3 * ones(1, U);

    % Initialise stats
    stats.scheduler          = scheduler_name;
    stats.arrivals.embb      = 0;   stats.arrivals.urllc     = 0;
    stats.arrived_bits.embb  = 0;   stats.arrived_bits.urllc = 0;
    stats.delivered.embb     = 0;   stats.delivered.urllc    = 0;
    stats.drops.embb         = 0;   stats.drops.urllc        = 0;
    stats.delays_s.embb      = [];  stats.delays_s.urllc     = [];
    stats.served_bits.embb   = 0;   stats.served_bits.urllc  = 0;
    stats.served_user_bits   = zeros(1, U);
    stats.scheduled_users    = -ones(T, B);
    stats.backlog_bits       = zeros(T, 1);

    tx_power_W = 10^((CFG.tx_power_dBm - 30) / 10);
    noise_W    = 10^((trace.noise_dBm  - 30) / 10);

    for t = 1:T
        % Arrivals & deadline drops
        [queues, stats] = enqueuePackets(queues, trace.arrivals, t, CFG, stats);
        [queues, stats] = dropExpiredPackets(queues, t, stats);

        backlog_per_user = queueBacklog(queues);
        has_backlog      = backlog_per_user > 0;

        % Schedule
        switch scheduler_name
            case 'rr'
                [selected, rr_ptr] = rrScheduler(has_backlog, rr_ptr, B);
            case 'pf'
                rate_t   = squeeze(trace.rate_no_int_bps(t,:,:));
                selected = pfScheduler(has_backlog, rate_t, avg_user_rate, B, CFG.eps);
            case 'deadline'
                dl_left  = earliestDeadline(queues, t);
                rate_t   = squeeze(trace.rate_no_int_bps(t,:,:));
                selected = deadlineScheduler(has_backlog, dl_left, rate_t, B);
            otherwise
                error('Unknown scheduler: %s', scheduler_name);
        end

        stats.scheduled_users(t,:) = selected;
        inst_user_rate = zeros(1, U);

        % Serve scheduled users
        for b = 1:B
            u = selected(b);
            if u < 1, continue; end

            pl_bu_dB = trace.pl_dB(t, b, u);
            signal_W = tx_power_W * 10^(-pl_bu_dB / 10);

            interf_W = 0;
            for b2 = 1:B
                if b2 == b, continue; end
                if selected(b2) < 1, continue; end
                interf_W = interf_W + tx_power_W * 10^(-trace.pl_dB(t,b2,u) / 10);
            end

            sinr       = signal_W / (noise_W + interf_W + CFG.eps);
            rate_bps   = CFG.bandwidth_Hz * log2(1 + sinr);
            bit_budget = rate_bps * CFG.slot_s;

            [queues, served, stats] = servePackets(queues, u, bit_budget, t, CFG, stats);
            served_u = served.embb + served.urllc;

            stats.served_bits.embb  = stats.served_bits.embb  + served.embb;
            stats.served_bits.urllc = stats.served_bits.urllc + served.urllc;
            stats.served_user_bits(u) = stats.served_user_bits(u) + served_u;
            inst_user_rate(u) = inst_user_rate(u) + served_u / CFG.slot_s;
        end

        avg_user_rate = CFG.pf_alpha * avg_user_rate + (1-CFG.pf_alpha) * inst_user_rate;
        stats.backlog_bits(t) = sum(queueBacklog(queues));
    end
end
