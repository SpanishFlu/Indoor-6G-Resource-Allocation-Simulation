function [queues, stats] = dropExpiredPackets(queues, t, stats)
%DROPEXPIREDPACKETS  Remove packets whose deadline has passed.
    U = length(queues);
    for u = 1:U
        for ci = 1:2
            cls = {'embb','urllc'};  c = cls{ci};
            dq = queues{u}.(c);
            while ~isempty(dq) && dq{1}.expire_slot <= t
                dq(1) = [];
                stats.drops.(c) = stats.drops.(c) + 1;
            end
            queues{u}.(c) = dq;
        end
    end
end
