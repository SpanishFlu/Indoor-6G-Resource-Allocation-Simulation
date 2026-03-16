function avg_user_rate = updateAverageRate(CFG, avg_user_rate, inst_user_rate)
%UPDATEAVERAGERATE PF moving-average throughput update

    avg_user_rate = CFG.pf_alpha .* avg_user_rate + ...
                    (1.0 - CFG.pf_alpha) .* inst_user_rate;

end