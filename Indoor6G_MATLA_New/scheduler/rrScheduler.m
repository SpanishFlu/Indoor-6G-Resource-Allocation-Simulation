function [selected, rr_ptr] = rrScheduler(backlog_users, rr_ptr, n_bs)
%RRSCHEDULER  Round-robin scheduler.
%   FIX: Uses 0-based pointer internally to match Python's np.arange(B).

    U = length(backlog_users);
    selected = -ones(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        for k = 1:U
            u_idx = mod(rr_ptr(b), U);            % 0-based index
            rr_ptr(b) = mod(rr_ptr(b) + 1, U);
            u = u_idx + 1;                         % 1-based for MATLAB arrays
            if backlog_users(u) && ~used(u)
                selected(b) = u;
                used(u) = true;
                break;
            end
        end
    end
end
