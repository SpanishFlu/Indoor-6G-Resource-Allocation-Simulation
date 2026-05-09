function selected = pfScheduler(backlog_users, expected_rate_bu, avg_user_rate, n_bs, eps)
%PFSCHEDULER  Proportional-fair scheduler.
    U = length(backlog_users);
    selected = -ones(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        cand = find(backlog_users(:)' & ~used);
        if isempty(cand), continue; end
        metric = expected_rate_bu(b, cand) ./ (avg_user_rate(cand) + eps);
        [~, idx] = max(metric);
        pick = cand(idx);
        selected(b) = pick;
        used(pick) = true;
    end
end
