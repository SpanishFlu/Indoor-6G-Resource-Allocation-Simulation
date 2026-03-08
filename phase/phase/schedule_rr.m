function [selected, rr_ptr] = schedule_rr(backlog_users, rr_ptr, n_bs)

U = length(backlog_users);
selected = -ones(1, n_bs);
used = false(1, U);

for b = 1:n_bs
    for k = 1:U
        
        u = mod(rr_ptr(b)-1, U) + 1;
        rr_ptr(b) = mod(rr_ptr(b), U) + 1;
        
        if backlog_users(u) && ~used(u)
            selected(b) = u;
            used(u) = true;
            break
        end
        
    end
end

end