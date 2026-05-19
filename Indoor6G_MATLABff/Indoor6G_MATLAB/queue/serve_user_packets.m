function [queues, served, stats] = serve_user_packets(queues, u, bit_budget, t, cfg, stats)
% SERVE_USER_PACKETS  Serve URLLC first, then eMBB from user u's queue.
%   [queues, served, stats] = serve_user_packets(queues, u, bit_budget, t, cfg, stats)
%   served is struct with fields embb and urllc (bits served).

    served.embb  = 0.0;
    served.urllc = 0.0;

    classes = {'urllc', 'embb'};  % URLLC priority
    for ic = 1:2
        cls = classes{ic};
        dq = queues(u).(cls);
        delivered_field = ['delivered_' cls];
        delays_field    = ['delays_s_' cls];

        while bit_budget > 0.0 && ~isempty(dq)
            tx = min(bit_budget, dq(1).remaining);
            dq(1).remaining = dq(1).remaining - tx;
            bit_budget = bit_budget - tx;
            served.(cls) = served.(cls) + tx;

            if dq(1).remaining <= 1e-12
                % packet fully delivered
                stats.(delivered_field) = stats.(delivered_field) + 1;
                delay_s = (t + 1 - dq(1).arrival_slot) * cfg.slot_s;
                stats.(delays_field)(end+1) = delay_s;
                dq(1) = [];
            end
        end

        queues(u).(cls) = dq;

        if bit_budget <= 0.0
            break;
        end
    end
end
