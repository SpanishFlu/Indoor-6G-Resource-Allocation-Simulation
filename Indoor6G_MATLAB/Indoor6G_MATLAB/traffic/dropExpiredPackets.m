function [queues, stats] = dropExpiredPackets(queues, t, stats)
%DROPEXPIREDPACKETS Drop packets whose deadlines expired by slot t

    U = numel(queues);
    classes = {'embb', 'urllc'};

    for u = 1:U
        for i = 1:numel(classes)
            cls = classes{i};

            while ~isempty(queues(u).(cls)) && queues(u).(cls){1}.expire_slot <= t
                queues(u).(cls)(1) = [];
                stats.drops.(cls) = stats.drops.(cls) + 1;
            end
        end
    end

end