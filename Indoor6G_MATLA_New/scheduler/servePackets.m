function [queues, served, stats] = servePackets(queues, u, bit_budget, t, CFG, stats)
%SERVEPACKETS  Drain URLLC then eMBB packets from a user's queue.
    served.embb  = 0;
    served.urllc = 0;

    for ci = 1:2
        cls = {'urllc','embb'};  c = cls{ci};
        dq = queues{u}.(c);
        while bit_budget > 0 && ~isempty(dq)
            pkt = dq{1};
            tx  = min(bit_budget, pkt.remaining);
            pkt.remaining = pkt.remaining - tx;
            bit_budget    = bit_budget - tx;
            served.(c)    = served.(c) + tx;

            if pkt.remaining <= 1e-12
                dq(1) = [];
                stats.delivered.(c) = stats.delivered.(c) + 1;
                delay_s = (t + 1 - pkt.arrival_slot) * CFG.slot_s;
                stats.delays_s.(c)(end+1) = delay_s;
            else
                dq{1} = pkt;
            end
        end
        queues{u}.(c) = dq;
        if bit_budget <= 0, break; end
    end
end
