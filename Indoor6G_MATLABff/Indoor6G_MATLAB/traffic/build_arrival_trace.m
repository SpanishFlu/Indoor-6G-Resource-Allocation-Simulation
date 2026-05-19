function arrivals = build_arrival_trace(cfg)
% BUILD_ARRIVAL_TRACE  Generate Bernoulli packet arrival trace.
%   arrivals = build_arrival_trace(cfg)
%   Returns struct with fields embb_bits(T,U) and urllc_bits(T,U).

    T = cfg.n_slots;
    U = cfg.n_robots;

    embb_bits  = zeros(T, U);
    urllc_bits = zeros(T, U);

    p_e = cfg.traffic.embb.arrival_prob;
    p_u = cfg.traffic.urllc.arrival_prob;

    embb_mask  = rand(T, U) < p_e;
    urllc_mask = rand(T, U) < p_u;

    % random integer packet sizes for arrivals
    n_embb  = sum(embb_mask(:));
    n_urllc = sum(urllc_mask(:));

    embb_bits(embb_mask)   = randi([cfg.traffic.embb.bits_min, ...
                                     cfg.traffic.embb.bits_max], n_embb, 1);
    urllc_bits(urllc_mask) = randi([cfg.traffic.urllc.bits_min, ...
                                     cfg.traffic.urllc.bits_max], n_urllc, 1);

    arrivals.embb_bits  = embb_bits;
    arrivals.urllc_bits = urllc_bits;
end
