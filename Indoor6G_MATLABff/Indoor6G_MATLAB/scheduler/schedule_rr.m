function [selected, rr_ptr] = schedule_rr(has_backlog, rr_ptr, n_bs)
% SCHEDULE_RR  Round Robin scheduler — one user per BS.
%   [selected, rr_ptr] = schedule_rr(has_backlog, rr_ptr, n_bs)
%   has_backlog: 1xU logical
%   rr_ptr:      1xB pointer (1-based)
%   selected:    1xB user index (0 = no user scheduled)

    U = length(has_backlog);
    selected = zeros(1, n_bs);  % 0 means no user
    used = false(1, U);

    for b = 1:n_bs
        for trial = 1:U
            u = rr_ptr(b);
            rr_ptr(b) = mod(rr_ptr(b), U) + 1;  % advance pointer (1-based wrap)
            if has_backlog(u) && ~used(u)
                selected(b) = u;
                used(u) = true;
                break;
            end
        end
    end
end
