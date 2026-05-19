function [queues, stats] = add_arrivals_to_queues(queues, arrivals, t, cfg, stats)
% ADD_ARRIVALS_TO_QUEUES  Enqueue new packets arriving at slot t.
%   [queues, stats] = add_arrivals_to_queues(queues, arrivals, t, cfg, stats)

    U = length(queues);

    for u = 1:U
        bits_e = arrivals.embb_bits(t, u);
        bits_u = arrivals.urllc_bits(t, u);

        if bits_e > 0
            pkt.remaining    = bits_e;
            pkt.arrival_slot = t;
            pkt.expire_slot  = t + cfg.traffic.embb.deadline_slots;
            queues(u).embb(end+1) = pkt;
            stats.arrivals_embb     = stats.arrivals_embb + 1;
            stats.arrived_bits_embb = stats.arrived_bits_embb + bits_e;
        end

        if bits_u > 0
            pkt.remaining    = bits_u;
            pkt.arrival_slot = t;
            pkt.expire_slot  = t + cfg.traffic.urllc.deadline_slots;
            queues(u).urllc(end+1) = pkt;
            stats.arrivals_urllc     = stats.arrivals_urllc + 1;
            stats.arrived_bits_urllc = stats.arrived_bits_urllc + bits_u;
        end
    end
end
