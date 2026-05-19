function [queues, stats] = drop_expired_packets(queues, t, stats)
% DROP_EXPIRED_PACKETS  Remove packets whose deadline has passed.
%   [queues, stats] = drop_expired_packets(queues, t, stats)

    classes = {'embb', 'urllc'};
    for u = 1:length(queues)
        for ic = 1:2
            cls = classes{ic};
            dq = queues(u).(cls);
            drop_field = ['drops_' cls];
            while ~isempty(dq) && dq(1).expire_slot <= t
                dq(1) = [];
                stats.(drop_field) = stats.(drop_field) + 1;
            end
            queues(u).(cls) = dq;
        end
    end
end
