function selected = deadlineScheduler(backlog_users, deadline_remaining_u, expected_rate_bu, n_bs)
%DEADLINESCHEDULER  Earliest-deadline-first with rate tie-break.
    U = length(backlog_users);
    selected = -ones(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        cand = find(backlog_users(:)' & ~used);
        if isempty(cand), continue; end

        best_u = -1;  best_dl = inf;  best_rate = -1;
        for i = 1:length(cand)
            u    = cand(i);
            dl   = deadline_remaining_u(u);
            rate = expected_rate_bu(b, u);
            if dl < best_dl || (dl == best_dl && rate > best_rate)
                best_dl = dl;  best_rate = rate;  best_u = u;
            end
        end
        selected(b) = best_u;
        used(best_u) = true;
    end
end
