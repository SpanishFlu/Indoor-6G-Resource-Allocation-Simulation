function arrivals = build_arrival_trace(cfg)
% BUILD_ARRIVAL_TRACE  Generate Bernoulli packet arrival trace.
%   arrivals = build_arrival_trace(cfg)
%   Returns struct with fields embb_bits(T,U) and urllc_bits(T,U).
%
%   Robots have DEDICATED traffic roles (no robot generates both types):
%     robots 1 .. n_embb_robots                    -> eMBB only
%     robots n_embb_robots+1 .. n_robots            -> URLLC only

    T = cfg.n_slots;
    U = cfg.n_robots;

    embb_bits  = zeros(T, U);
    urllc_bits = zeros(T, U);

    p_e = cfg.traffic.embb.arrival_prob;
    p_u = cfg.traffic.urllc.arrival_prob;

    embb_robots  = 1 : cfg.n_embb_robots;
    urllc_robots = (cfg.n_embb_robots + 1) : (cfg.n_embb_robots + cfg.n_urllc_robots);

    embb_mask  = false(T, U);
    urllc_mask = false(T, U);
    embb_mask(:, embb_robots)   = rand(T, length(embb_robots))  < p_e;
    urllc_mask(:, urllc_robots) = rand(T, length(urllc_robots)) < p_u;

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
