function [queues, stats] = drop_expired_packets(queues, t, stats)

U = length(queues);

for u = 1:U

    classes = {"embb","urllc"};

    for c = 1:length(classes)

        cls = classes{c};

        dq = queues{u}.(cls);

        while ~isempty(dq) && dq{1}.expire_slot <= t

            dq(1) = [];
            stats.drops.(cls) = stats.drops.(cls) + 1;

        end

        queues{u}.(cls) = dq;

    end

end

end