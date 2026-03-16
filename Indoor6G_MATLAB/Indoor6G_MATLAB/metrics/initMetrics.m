function stats = initMetrics(CFG, scheduler_name)
%INITMETRICS Initialize simulation statistics

    U = CFG.n_robots;
    T = CFG.n_slots;
    B = CFG.n_bs;

    stats = struct();
    stats.scheduler = scheduler_name;

    stats.arrivals = struct('embb', 0, 'urllc', 0);
    stats.arrived_bits = struct('embb', 0.0, 'urllc', 0.0);

    stats.delivered = struct('embb', 0, 'urllc', 0);
    stats.drops = struct('embb', 0, 'urllc', 0);

    stats.delays_s = struct('embb', [], 'urllc', []);

    stats.served_bits = struct('embb', 0.0, 'urllc', 0.0);
    stats.served_user_bits = zeros(1, U);

    stats.scheduled_users = -ones(T, B);
    stats.backlog_bits = zeros(T, 1);

end