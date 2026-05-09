function rem = earliestDeadline(queues, now_slot)
%EARLIESTDEADLINE  Slots remaining until each user's most urgent packet expires.
    U = length(queues);
    rem = inf(1, U);
    for u = 1:U
        for ci = 1:2
            cls = {'urllc','embb'};  c = cls{ci};
            q = queues{u}.(c);
            if ~isempty(q)
                rem(u) = min(rem(u), q{1}.expire_slot - now_slot);
            end
        end
    end
end
