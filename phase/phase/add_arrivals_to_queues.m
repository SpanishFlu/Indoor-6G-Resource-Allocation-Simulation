function [queues, stats] = add_arrivals_to_queues(queues, arrivals, t, cfg, stats)

U = length(queues);

arr_u = size(arrivals.embb_bits,2);

if arr_u ~= U
    error("Trace/CFG mismatch: arrivals users != queues users. Rebuild trace.");
end

for u = 1:U

    bits_e = arrivals.embb_bits(t,u);
    bits_u = arrivals.urllc_bits(t,u);

    if bits_e > 0

        pkt.remaining = bits_e;
        pkt.arrival_slot = t;
        pkt.expire_slot = t + cfg.traffic.embb.deadline_slots;

        queues{u}.embb{end+1} = pkt;

        stats.arrivals.embb = stats.arrivals.embb + 1;
        stats.arrived_bits.embb = stats.arrived_bits.embb + bits_e;

    end

    if bits_u > 0

        pkt.remaining = bits_u;
        pkt.arrival_slot = t;
        pkt.expire_slot = t + cfg.traffic.urllc.deadline_slots;

        queues{u}.urllc{end+1} = pkt;

        stats.arrivals.urllc = stats.arrivals.urllc + 1;
        stats.arrived_bits.urllc = stats.arrived_bits.urllc + bits_u;

    end

end

end