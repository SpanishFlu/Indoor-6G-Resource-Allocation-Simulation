function rem = earliest_deadline_remaining_slots(queues, now_slot)
% EARLIEST_DEADLINE_REMAINING_SLOTS  Urgency metric per user.
%   rem = earliest_deadline_remaining_slots(queues, now_slot)
%   Smaller value = more urgent.

    U = length(queues);
    rem = Inf(1, U);

    classes = {'urllc', 'embb'};
    for u = 1:U
        for ic = 1:2
            cls = classes{ic};
            q = queues(u).(cls);
            if ~isempty(q)
                rem(u) = min(rem(u), q(1).expire_slot - now_slot);
            end
        end
    end
end
