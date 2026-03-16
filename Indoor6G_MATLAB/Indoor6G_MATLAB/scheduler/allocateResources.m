function [queues, stats, avg_user_rate, rr_ptr] = allocateResources(CFG, trace, queues, stats, avg_user_rate, rr_ptr, t)
%ALLOCATERESOURCES Run one simulation slot:
% arrivals, deadline drops, scheduling, SINR/rate, packet service

    B = CFG.n_bs;
    U = CFG.n_robots;

    tx_power_W = 10.^((CFG.tx_power_dBm - 30.0) ./ 10.0);
    noise_W = 10.^((trace.noise_dBm - 30.0) ./ 10.0);

    % arrivals and deadline drops
    [queues, stats] = enqueuePackets(queues, trace.arrivals, t, CFG, stats);
    [queues, stats] = dropExpiredPackets(queues, t, stats);

    % users with pending packets
    backlog_per_user = queueBacklogBits(queues);
    has_backlog = backlog_per_user > 0.0;

    % schedule per BS
    [selected, rr_ptr] = pfScheduler( ...
        stats.scheduler, ...
        has_backlog, ...
        squeeze(trace.rate_no_int_bps(t, :, :)), ...
        avg_user_rate, ...
        B, ...
        rr_ptr, ...
        queues, ...
        t, ...
        CFG.eps);

    stats.scheduled_users(t, :) = selected;

    inst_user_rate = zeros(1, U);

    for b = 1:B
        u = selected(b);
        if u < 0
            continue;
        end

        % desired signal
        pl_bu_dB = trace.pl_dB(t, b, u);
        signal_W = tx_power_W .* 10.^(-pl_bu_dB ./ 10.0);

        % interference from other active BS
        interf_W = 0.0;
        for b2 = 1:B
            if b2 == b
                continue;
            end
            if selected(b2) < 0
                continue;
            end

            pl_b2u_dB = trace.pl_dB(t, b2, u);
            interf_W = interf_W + tx_power_W .* 10.^(-pl_b2u_dB ./ 10.0);
        end

        sinr = signal_W ./ (noise_W + interf_W + CFG.eps);
        rate_bps = CFG.bandwidth_Hz .* log2(1.0 + sinr);
        bit_budget = rate_bps .* CFG.slot_s;

        [queues, stats, served_u] = serveUserPackets(queues, u, bit_budget, t, CFG, stats);
        stats.served_user_bits(u) = stats.served_user_bits(u) + served_u;
        inst_user_rate(u) = inst_user_rate(u) + served_u ./ CFG.slot_s;
    end

    avg_user_rate = updateAverageRate(CFG, avg_user_rate, inst_user_rate);
    stats.backlog_bits(t) = sum(queueBacklogBits(queues));
end

function per_user = queueBacklogBits(queues)
%QUEUEBACKLOGBITS Total queued bits per user

    U = numel(queues);
    per_user = zeros(1, U);

    for u = 1:U
        embb_sum = 0.0;
        urllc_sum = 0.0;

        for k = 1:numel(queues(u).embb)
            embb_sum = embb_sum + queues(u).embb{k}.remaining;
        end

        for k = 1:numel(queues(u).urllc)
            urllc_sum = urllc_sum + queues(u).urllc{k}.remaining;
        end

        per_user(u) = embb_sum + urllc_sum;
    end
end

function [queues, stats, served_u] = serveUserPackets(queues, u, bit_budget, t, CFG, stats)
%SERVEUSERPACKETS Serve URLLC first, then eMBB

    served_embb = 0.0;
    served_urllc = 0.0;

    classes = {'urllc', 'embb'};
    for i = 1:numel(classes)
        cls = classes{i};

        while bit_budget > 0.0 && ~isempty(queues(u).(cls))
            pkt = queues(u).(cls){1};

            tx = min(bit_budget, pkt.remaining);
            pkt.remaining = pkt.remaining - tx;
            bit_budget = bit_budget - tx;

            if strcmp(cls, 'embb')
                served_embb = served_embb + tx;
            else
                served_urllc = served_urllc + tx;
            end

            if pkt.remaining <= 1e-12
                queues(u).(cls)(1) = [];
                stats.delivered.(cls) = stats.delivered.(cls) + 1;
                delay_s = (t + 1 - pkt.arrival_slot) * CFG.slot_s;
                stats.delays_s.(cls)(end+1) = delay_s; %#ok<AGROW>
            else
                queues(u).(cls){1} = pkt;
            end
        end

        if bit_budget <= 0.0
            break;
        end
    end

    stats.served_bits.embb = stats.served_bits.embb + served_embb;
    stats.served_bits.urllc = stats.served_bits.urllc + served_urllc;

    served_u = served_embb + served_urllc;
end