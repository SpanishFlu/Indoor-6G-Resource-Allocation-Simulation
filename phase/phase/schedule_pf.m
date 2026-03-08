function selected = schedule_pf(backlog_users, expected_rate_bu, avg_user_rate, n_bs)

U = length(backlog_users);
eps = 1e-9;

selected = -ones(1, n_bs);
used = false(1, U);

for b = 1:n_bs
    
    cand = [];
    
    for u = 1:U
        if backlog_users(u) && ~used(u)
            cand = [cand u];
        end
    end
    
    if isempty(cand)
        continue
    end
    
    metric = expected_rate_bu(b, cand) ./ (avg_user_rate(cand) + eps);
    [~, idx] = max(metric);
    
    pick = cand(idx);
    
    selected(b) = pick;
    used(pick) = true;

end

end