function stats = run_simulation(cfg, trace, scheduler_name, bw_method, slot_class_id)
% RUN_SIMULATION  End-to-end simulation for one scheduler.
%   stats = run_simulation(cfg, trace, scheduler_name, bw_method, slot_class_id)
%   scheduler_name: 'rr', 'pf', or 'deadline'
%   bw_method (optional, PF only, default 'shannon'):
%     'flat'    - original flat system bandwidth (no classification)
%     'shannon' - Method A: per-slot class-derived effective bandwidth,
%                 rate = BW_eff * log2(1+SINR)
%     'rb'      - Method B: per-slot class -> N_RB + per-service (eMBB/
%                 URLLC) fixed-MCS resource-block formula, rate =
%                 N_RB*12*14*Qm*Rcode*(1-OH)/T_slot (no SINR dependence)
%   Also accepts a logical for backward compatibility: true->'shannon',
%   false->'flat'.
%   slot_class_id (optional, Tx1): precomputed ground-truth class per
%   slot, from dataset/classify_all_slots.m. When supplied, PF reuses
%   these EXACT labels (via class_to_numerology_guard) instead of
%   re-deriving classification with its own independent random draws —
%   this is what keeps the scheduler and the exported waveform_dataset.csv
%   consistent with each other. If omitted, falls back to live per-slot
%   classification (legacy behavior).

    if nargin < 4
        bw_method = 'shannon';
    end
    if islogical(bw_method)
        if bw_method, bw_method = 'shannon'; else, bw_method = 'flat'; end
    end
    if nargin < 5
        slot_class_id = [];
    end

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
    stats.bw_method         = bw_method;
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

    % PF-only: per-slot waveform class and resulting effective bandwidth
    is_pf = strcmpi(scheduler_name, 'pf') && ~strcmpi(bw_method, 'flat');
    use_rb_method = is_pf && strcmpi(bw_method, 'rb');
    use_shared_labels = is_pf && ~isempty(slot_class_id);
    stats.slot_class_id  = zeros(T, 1);
    stats.slot_bw_eff_Hz = cfg.bandwidth_Hz * ones(T, 1);  % default = full BW
    stats.slot_N_RB      = zeros(T, 1);

    % Dedicated robot roles (1=eMBB, 2=URLLC) — needed for Method B, which
    % applies a different fixed MCS per service type.
    robot_role = ones(1, U);  % default eMBB
    robot_role(cfg.n_embb_robots + 1 : end) = 2;  % URLLC

    embb_mcs  = service_mcs_params('embb');
    urllc_mcs = service_mcs_params('urllc');

    % 5G NR numerology reference table (indexed by numerology 1..4)
    scs_khz_tbl   = [15, 30, 60, 120];
    t_slot_ms_tbl = [1, 0.5, 0.25, 0.125];
    n_symb        = 14;

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

        % PF-only: get this slot's waveform class (numerology + guard band)
        % and derive the resulting effective bandwidth/noise (Method A) or
        % RB count (Method B). RR and Deadline are left untouched.
        if is_pf
            if use_shared_labels
                % Reuse the SAME ground-truth label the exported dataset
                % uses for this slot — no independent random re-draw.
                class_id_t = slot_class_id(t);
                [numerology_t, guard_band_t] = class_to_numerology_guard(class_id_t);
            else
                % Legacy fallback: live per-slot classification.
                feat = extract_slot_features(cfg, trace, t);
                numerology_t = assign_numerology(feat(5), feat(6), feat(3));
                guard_band_t = assign_guard_band(feat(2));
                class_id_t   = assign_class(guard_band_t, numerology_t);
            end

            frac_t      = class_bandwidth_fraction(numerology_t, guard_band_t);
            bw_eff_Hz_t = cfg.bandwidth_Hz * frac_t;
            noise_dBm_t = -174 + 10*log10(bw_eff_Hz_t) + cfg.noise_figure_dB;
            noise_W_t   = 10^((noise_dBm_t - 30) / 10);

            stats.slot_class_id(t)  = class_id_t;
            stats.slot_bw_eff_Hz(t) = bw_eff_Hz_t;

            if use_rb_method
                rb_bw_Hz    = 12 * scs_khz_tbl(numerology_t) * 1e3;
                N_RB_t      = floor(bw_eff_Hz_t / rb_bw_Hz);
                T_slot_s_t  = t_slot_ms_tbl(numerology_t) / 1e3;
                stats.slot_N_RB(t) = N_RB_t;
            end
        else
            bw_eff_Hz_t = cfg.bandwidth_Hz;
            noise_W_t   = noise_W;
        end

        inst_user_rate = zeros(1, U);

        % 4) Transmit and serve
        for b = 1:B
            u = selected(b);
            if u == 0
                continue;
            end

            if use_rb_method
                % Method B: fixed-MCS resource-block formula, no SINR
                % dependence — rate is determined purely by the class's
                % RB count, the numerology's slot timing, and the user's
                % own service-type MCS.
                if robot_role(u) == 1
                    mcs = embb_mcs;
                else
                    mcs = urllc_mcs;
                end
                rate_bps = N_RB_t * 12 * n_symb * mcs.Qm * mcs.Rcode * (1 - mcs.OH) / T_slot_s_t;
            else
                % Method A ('shannon') or 'flat': channel-quality-driven rate
                pl_bu_dB = trace.pl_dB(t, b, u);
                signal_W = tx_power_W * 10^(-pl_bu_dB / 10);

                interf_W = 0.0;
                for b2 = 1:B
                    if b2 == b, continue; end
                    if selected(b2) == 0, continue; end
                    pl_b2u_dB = trace.pl_dB(t, b2, u);
                    interf_W = interf_W + tx_power_W * 10^(-pl_b2u_dB / 10);
                end

                sinr = signal_W / (noise_W_t + interf_W + cfg.eps);
                rate_bps = bw_eff_Hz_t * log2(1.0 + sinr);
            end

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
