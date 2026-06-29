function rb_alloc = allocate_rbs(scheduler_name, has_backlog, ...
                                  sinr_bu, avg_user_rate, ...
                                  deadline_left, n_rb, eps)
% ALLOCATE_RBS  Assign N_RB resource blocks to robots for one slot.
%
%   rb_alloc(rb) = robot index (0 = unallocated)
%
%   RR:       cyclic allocation across robots with backlog
%   PF:       each RB → robot with highest inst_rate/avg_rate
%   Deadline: each RB → robot with smallest deadline remaining

    U = length(has_backlog);
    rb_alloc = zeros(1, n_rb);

    cand = find(has_backlog);
    if isempty(cand); return; end

    switch scheduler_name
        % ── Round Robin ──────────────────────────────────────────────────
        case 'rr'
            ptr = 1;
            for rb = 1:n_rb
                % find next candidate with backlog (wrap around)
                for trial = 1:length(cand)
                    u = cand(mod(ptr-1, length(cand))+1);
                    ptr = ptr + 1;
                    rb_alloc(rb) = u;
                    break;
                end
            end

        % ── Proportional Fair ────────────────────────────────────────────
        case 'pf'
            % sinr_bu is (n_rb x U) — use BS1 (row 1) for metric
            % For multi-BS we pick the best BS per robot
            if size(sinr_bu,1) == 1
                inst_rate = sinr_bu(1, :);
            else
                inst_rate = max(sinr_bu, [], 1);  % best BS per robot
            end
            rb_bw = size(sinr_bu,1);  % placeholder — actual bw passed via sinr already
            for rb = 1:n_rb
                metric = zeros(1,U);
                metric(cand) = inst_rate(cand) ./ (avg_user_rate(cand) + eps);
                [~,best] = max(metric);
                rb_alloc(rb) = best;
            end

        % ── Deadline-Aware ───────────────────────────────────────────────
        case 'deadline'
            for rb = 1:n_rb
                best_u = cand(1); best_dl = deadline_left(cand(1));
                best_sinr = -Inf;
                if size(sinr_bu,1)==1; sinr_row=sinr_bu(1,:);
                else; sinr_row=max(sinr_bu,[],1); end
                for ci = 1:length(cand)
                    u = cand(ci);
                    dl = deadline_left(u);
                    if dl < best_dl || (dl==best_dl && sinr_row(u)>best_sinr)
                        best_dl=dl; best_sinr=sinr_row(u); best_u=u;
                    end
                end
                rb_alloc(rb) = best_u;
            end
    end
end
