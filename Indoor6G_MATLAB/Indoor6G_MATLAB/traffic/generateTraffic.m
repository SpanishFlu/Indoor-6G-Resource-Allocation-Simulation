function arrivals = generateTraffic(CFG)
%GENERATETRAFFIC Build Bernoulli packet-arrival trace
%
% Output:
%   arrivals.embb_bits  -> [T x U]
%   arrivals.urllc_bits -> [T x U]

    T = CFG.n_slots;
    U = CFG.n_robots;

    embb_bits = zeros(T, U);
    urllc_bits = zeros(T, U);

    p_e = CFG.traffic.embb.arrival_prob;
    p_u = CFG.traffic.urllc.arrival_prob;

    embb_mask = rand(T, U) < p_e;
    urllc_mask = rand(T, U) < p_u;

    n_embb = nnz(embb_mask);
    n_urllc = nnz(urllc_mask);

    if n_embb > 0
        embb_bits(embb_mask) = randi( ...
            [CFG.traffic.embb.bits_min, CFG.traffic.embb.bits_max], ...
            n_embb, 1);
    end

    if n_urllc > 0
        urllc_bits(urllc_mask) = randi( ...
            [CFG.traffic.urllc.bits_min, CFG.traffic.urllc.bits_max], ...
            n_urllc, 1);
    end

    arrivals = struct();
    arrivals.embb_bits = embb_bits;
    arrivals.urllc_bits = urllc_bits;

end