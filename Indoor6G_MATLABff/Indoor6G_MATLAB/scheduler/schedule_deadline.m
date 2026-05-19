function selected = schedule_deadline(has_backlog, deadline_remaining_u, expected_rate_bu, n_bs)
% SCHEDULE_DEADLINE  Earliest-deadline-first scheduler.
%   selected = schedule_deadline(has_backlog, deadline_remaining_u, expected_rate_bu, n_bs)
%   Tie-break: higher expected rate on that BS.

    U = length(has_backlog);
    selected = zeros(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        cand = find(has_backlog & ~used);
        if isempty(cand)
            continue;
        end

        best_u = 0;
        best_deadline = Inf;
        best_rate = -1.0;

        for ci = 1:length(cand)
            u = cand(ci);
            dleft = deadline_remaining_u(u);
            rate  = expected_rate_bu(b, u);
            if (dleft < best_deadline) || (dleft == best_deadline && rate > best_rate)
                best_deadline = dleft;
                best_rate = rate;
                best_u = u;
            end
        end

        selected(b) = best_u;
        used(best_u) = true;
    end
end
