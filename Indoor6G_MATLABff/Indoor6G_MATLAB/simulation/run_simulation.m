function stats = run_simulation(cfg, trace, scheduler_name)
% RUN_SIMULATION  End-to-end simulation for one scheduler.
%   stats = run_simulation(cfg, trace, scheduler_name)
%   scheduler_name: 'rr', 'pf', or 'deadline'

    T = cfg.n_slots;
    B = cfg.n_bs;
    U = cfg.n_robots;

    queues = init_queues(U);

    % RR pointers (1-based, one per BS)
    rr_ptr = 1:B;

    % PF moving-average throughput
    avg_user_rate = 1e3 * ones(1, U);

    % --- Initialize stats struct ---
    stats.scheduler        = scheduler_name;
    stats.arrivals_embb    = 0;
    stats.arrivals_urllc   = 0;
    stats.arrived_bits_embb  = 0.0;
    stats.arrived_bits_urllc = 0.0;
    stats.delivered_embb   = 0;
    stats.delivered_urllc  = 0;
    stats.drops_embb       = 0;
    stats.drops_urllc      = 0;
    stats.delays_s_embb    = [];
    stats.delays_s_urllc   = [];
    stats.served_bits_embb  = 0.0;
    stats.served_bits_urllc = 0.0;
    stats.served_user_bits  = zeros(1, U);
    stats.scheduled_users   = zeros(T, B);  % 0 means no user
    stats.backlog_bits      = zeros(T, 1);

    % Pre-compute TX power and noise in watts
    tx_power_W = 10^((cfg.tx_power_dBm - 30) / 10);
    noise_W    = 10^((trace.noise_dBm - 30) / 10);

    % --- Main simulation loop ---
    for t = 1:T
        % 1) Arrivals and deadline drops
        [queues, stats] = add_arrivals_to_queues(queues, trace.arrivals, t, cfg, stats);
        [queues, stats] = drop_expired_packets(queues, t, stats);

        % 2) Backlog check
        backlog_per_user = queue_backlog_bits(queues);
        has_backlog = backlog_per_user > 0.0;

        % 3) Schedule per BS
        if strcmpi(scheduler_name, 'rr')
            [selected, rr_ptr] = schedule_rr(has_backlog, rr_ptr, B);
        elseif strcmpi(scheduler_name, 'pf')
            % squeeze rate_no_int_bps(t,:,:) to B x U
            rate_t = squeeze(trace.rate_no_int_bps(t, :, :));
            if B == 1
                rate_t = rate_t(:)';  % ensure row = BS dimension
            end
            selected = schedule_pf(has_backlog, rate_t, avg_user_rate, B, cfg.eps);
        elseif strcmpi(scheduler_name, 'deadline')
            deadline_left = earliest_deadline_remaining_slots(queues, t);
            rate_t = squeeze(trace.rate_no_int_bps(t, :, :));
            if B == 1
                rate_t = rate_t(:)';
            end
            selected = schedule_deadline(has_backlog, deadline_left, rate_t, B);
        else
            error('scheduler_name must be ''rr'', ''pf'', or ''deadline''');
        end

        stats.scheduled_users(t, :) = selected;

        inst_user_rate = zeros(1, U);

        % 4) Transmit and serve
        for b = 1:B
            u = selected(b);
            if u == 0
                continue;
            end

            % desired signal
            pl_bu_dB = trace.pl_dB(t, b, u);
            signal_W = tx_power_W * 10^(-pl_bu_dB / 10);

            % interference from other active BS
            interf_W = 0.0;
            for b2 = 1:B
                if b2 == b, continue; end
                if selected(b2) == 0, continue; end
                pl_b2u_dB = trace.pl_dB(t, b2, u);
                interf_W = interf_W + tx_power_W * 10^(-pl_b2u_dB / 10);
            end

            sinr = signal_W / (noise_W + interf_W + cfg.eps);
            rate_bps = cfg.bandwidth_Hz * log2(1.0 + sinr);
            bit_budget = rate_bps * cfg.slot_s;

            [queues, served, stats] = serve_user_packets(queues, u, bit_budget, t, cfg, stats);
            served_u = served.embb + served.urllc;

            stats.served_bits_embb  = stats.served_bits_embb  + served.embb;
            stats.served_bits_urllc = stats.served_bits_urllc + served.urllc;
            stats.served_user_bits(u) = stats.served_user_bits(u) + served_u;
            inst_user_rate(u) = inst_user_rate(u) + served_u / cfg.slot_s;
        end

        % 5) PF moving-average update
        avg_user_rate = cfg.pf_alpha * avg_user_rate + (1.0 - cfg.pf_alpha) * inst_user_rate;

        % 6) Record backlog
        stats.backlog_bits(t) = sum(queue_backlog_bits(queues));
    end
end
