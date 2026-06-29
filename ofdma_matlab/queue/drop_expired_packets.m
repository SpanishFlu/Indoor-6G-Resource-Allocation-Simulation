function [queues,stats]=drop_expired_packets(queues,t,stats)
% DROP_EXPIRED_PACKETS  Remove packets past their deadline.
    classes={'embb','urllc'};
    for u=1:length(queues)
        for ic=1:2
            cls=classes{ic}; dq=queues(u).(cls);
            drop_f=['drops_' cls];
            while ~isempty(dq)&&dq(1).expire_slot<=t
                dq(1)=[]; stats.(drop_f)=stats.(drop_f)+1;
            end
            queues(u).(cls)=dq;
        end
    end
end
