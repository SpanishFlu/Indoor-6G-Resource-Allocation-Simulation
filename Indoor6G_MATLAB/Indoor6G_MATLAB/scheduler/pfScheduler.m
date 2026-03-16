function [selected, rr_ptr] = pfScheduler(method, backlog_users, expected_rate_bu, avg_user_rate, n_bs, rr_ptr, queues, now_slot, eps)
%PFSCHEDULER Scheduler wrapper supporting:
%   - 'rr'       : round robin
%   - 'pf'       : proportional fair
%   - 'deadline' : earliest deadline first, tie-break by expected rate
%
% Inputs:
%   method            : 'rr' | 'pf' | 'deadline'
%   backlog_users     : [1 x U] or [U x 1] logical/numeric
%   expected_rate_bu  : [B x U]
%   avg_user_rate     : [1 x U] or [U x 1]
%   n_bs              : number of BSs
%   rr_ptr            : [1 x B] RR pointer state (used for 'rr')
%   queues            : queue struct array (used for 'deadline')
%   now_slot          : current slot (used for 'deadline')
%   eps               : small guard for PF
%
% Outputs:
%   selected          : [1 x B], selected user per BS, -1 if none
%   rr_ptr            : updated RR pointer

    if nargin < 9 || isempty(eps)
        eps = 1e-9;
    end

    switch lower(method)
        case 'rr'
            [selected, rr_ptr] = scheduleRR(backlog_users, rr_ptr, n_bs);

        case 'pf'
            selected = schedulePF(backlog_users, expected_rate_bu, avg_user_rate, n_bs, eps);

        case 'deadline'
            deadline_remaining_u = earliestDeadlineRemainingSlots(queues, now_slot);
            selected = scheduleDeadline(backlog_users, deadline_remaining_u, expected_rate_bu, n_bs);

        otherwise
            error('Unknown scheduler method: %s', method);
    end
end

function [selected, rr_ptr] = scheduleRR(backlog_users, rr_ptr, n_bs)
% round robin scheduler

    U = numel(backlog_users);
    selected = -ones(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        for k = 1:U
            u = rr_ptr(b);
            rr_ptr(b) = mod(rr_ptr(b), U) + 1;

            if backlog_users(u) && ~used(u)
                selected(b) = u;
                used(u) = true;
                break;
            end
        end
    end
end

function selected = schedulePF(backlog_users, expected_rate_bu, avg_user_rate, n_bs, eps)
% proportional fair scheduler

    U = numel(backlog_users);
    selected = -ones(1, n_bs);
    used = false(1, U);

    avg_user_rate = avg_user_rate(:).';

    for b = 1:n_bs
        cand = find(backlog_users & ~used);
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

function rem = earliestDeadlineRemainingSlots(queues, now_slot)
% smaller value means more urgent packet deadline

    U = numel(queues);
    rem = inf(1, U);

    for u = 1:U
        for cls = {'urllc', 'embb'}
            q = queues(u).(cls{1});
            if ~isempty(q)
                rem(u) = min(rem(u), q{1}.expire_slot - now_slot);
            end
        end
    end
end

function selected = scheduleDeadline(backlog_users, deadline_remaining_u, expected_rate_bu, n_bs)
% earliest deadline first; tie-break with higher expected rate on each BS

    U = numel(backlog_users);
    selected = -ones(1, n_bs);
    used = false(1, U);

    for b = 1:n_bs
        cand = find(backlog_users & ~used);
        if isempty(cand)
            continue;
        end

        best_u = -1;
        best_deadline = inf;
        best_rate = -1.0;

        for ii = 1:numel(cand)
            u = cand(ii);
            dleft = deadline_remaining_u(u);
            rate = expected_rate_bu(b, u);

            if (dleft < best_deadline) || ...
               (dleft == best_deadline && rate > best_rate)
                best_deadline = dleft;
                best_rate = rate;
                best_u = u;
            end
        end

        selected(b) = best_u;
        used(best_u) = true;
    end
end