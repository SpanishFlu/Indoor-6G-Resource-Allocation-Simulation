function arrivals = generateTraffic(CFG)
%GENERATETRAFFIC  Bernoulli packet arrivals for all robots.
%   FIX: All robots receive BOTH eMBB and URLLC traffic (matching Python).
%   Masks are generated as full (T x U) matrices before filling bit sizes.

    T = CFG.n_slots;
    U = CFG.n_robots;

    % Generate masks for ALL robots at once (broadcast style, matching Python)
    embb_mask  = rand(T, U) < CFG.traffic.embb.arrival_prob;
    urllc_mask = rand(T, U) < CFG.traffic.urllc.arrival_prob;

    embb_bits  = zeros(T, U);
    urllc_bits = zeros(T, U);

    n_embb  = nnz(embb_mask);
    n_urllc = nnz(urllc_mask);

    embb_bits(embb_mask)   = randi([CFG.traffic.embb.bits_min, ...
                                     CFG.traffic.embb.bits_max], n_embb, 1);
    urllc_bits(urllc_mask) = randi([CFG.traffic.urllc.bits_min, ...
                                     CFG.traffic.urllc.bits_max], n_urllc, 1);

    arrivals.embb_bits  = embb_bits;
    arrivals.urllc_bits = urllc_bits;
end
