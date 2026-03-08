function [queues, served, stats] = serve_user_packets(queues, u, bit_budget, t, cfg, stats)

served.embb = 0;
served.urllc = 0;

classes = {"urllc","embb"};

for c = 1:length(classes)

    cls = classes{c};
    dq = queues{u}.(cls);

    while bit_budget > 0 && ~isempty(dq)

        pkt = dq{1};

        tx = min(bit_budget, pkt.remaining);

        pkt.remaining = pkt.remaining - tx;
        bit_budget = bit_budget - tx;

        served.(cls) = served.(cls) + tx;

        if pkt.remaining <= 1e-12

            dq(1) = [];

            stats.delivered.(cls) = stats.delivered.(cls) + 1;

            delay_s = (t + 1 - pkt.arrival_slot) * cfg.slot_s;
            stats.delays_s.(cls)(end+1) = delay_s;

        else

            dq{1} = pkt;

        end

    end

    queues{u}.(cls) = dq;

    if bit_budget <= 0
        break
    end

end

end