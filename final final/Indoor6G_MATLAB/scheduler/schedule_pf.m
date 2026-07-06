function selected = schedule_pf(has_backlog, expected_rate_bu, avg_user_rate, n_bs, eps)
% SCHEDULE_PF  Proportional Fair scheduler — one user per BS.
%   selected = schedule_pf(has_backlog, expected_rate_bu, avg_user_rate, n_bs, eps)
%   expected_rate_bu: B x U matrix of instantaneous rates
%   avg_user_rate:    1 x U EWMA throughput

    U = length(has_backlog);
    selected = zeros(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        cand = find(has_backlog & ~used);
        if isempty(cand)
            continue;
        end
        metric = expected_rate_bu(b, cand) ./ (avg_user_rate(cand) + eps);
        [~, idx] = max(metric);
        pick = cand(idx);
        selected(b) = pick;
        used(pick) = true;
    end
end
