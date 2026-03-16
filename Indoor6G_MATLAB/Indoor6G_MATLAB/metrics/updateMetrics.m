function stats = updateMetrics(CFG, trace, scheduler_name)
%UPDATEMETRICS Run the full simulation and return stats

    U = CFG.n_robots;
    T = CFG.n_slots;
    B = CFG.n_bs;

    queues = initQueues(U);
    rr_ptr = ones(1, B);
    avg_user_rate = 1e3 * ones(1, U);

    stats = initMetrics(CFG, scheduler_name);

    for t = 1:T
        [queues, stats, avg_user_rate, rr_ptr] = ...
            allocateResources(CFG, trace, queues, stats, avg_user_rate, rr_ptr, t);
    end
end