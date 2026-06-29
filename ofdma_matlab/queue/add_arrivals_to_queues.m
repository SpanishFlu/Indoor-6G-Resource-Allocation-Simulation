function [queues,stats]=add_arrivals_to_queues(queues,arrivals,t,cfg,stats)
% ADD_ARRIVALS_TO_QUEUES  Enqueue packets arriving at slot t.
    U=length(queues);
    for u=1:U
        be=arrivals.embb_bits(t,u); bu=arrivals.urllc_bits(t,u);
        if be>0
            pkt.remaining=be; pkt.arrival_slot=t;
            pkt.expire_slot=t+cfg.traffic.embb.deadline_slots;
            queues(u).embb(end+1)=pkt;
            stats.arrivals_embb=stats.arrivals_embb+1;
            stats.arrived_bits_embb=stats.arrived_bits_embb+be;
        end
        if bu>0
            pkt.remaining=bu; pkt.arrival_slot=t;
            pkt.expire_slot=t+cfg.traffic.urllc.deadline_slots;
            queues(u).urllc(end+1)=pkt;
            stats.arrivals_urllc=stats.arrivals_urllc+1;
            stats.arrived_bits_urllc=stats.arrived_bits_urllc+bu;
        end
    end
end
