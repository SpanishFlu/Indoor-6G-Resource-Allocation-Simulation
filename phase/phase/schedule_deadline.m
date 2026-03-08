function selected = schedule_deadline(backlog_users, deadline_remaining_u, expected_rate_bu, n_bs)

U = length(backlog_users);

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
    
    best_u = -1;
    best_deadline = inf;
    best_rate = -1;
    
    for i = 1:length(cand)
        
        u = cand(i);
        dleft = deadline_remaining_u(u);
        rate = expected_rate_bu(b, u);
        
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