function arrivals = build_arrival_trace(cfg)

T = cfg.n_slots;
U = cfg.n_robots;

embb_bits = zeros(T,U);
urllc_bits = zeros(T,U);

p_e = cfg.traffic.embb.arrival_prob;
p_u = cfg.traffic.urllc.arrival_prob;

embb_mask = rand(T,U) < p_e;
urllc_mask = rand(T,U) < p_u;

% eMBB packets
n_e = nnz(embb_mask);
embb_bits(embb_mask) = randi([ ...
    cfg.traffic.embb.bits_min ...
    cfg.traffic.embb.bits_max], n_e,1);

% URLLC packets
n_u = nnz(urllc_mask);
urllc_bits(urllc_mask) = randi([ ...
    cfg.traffic.urllc.bits_min ...
    cfg.traffic.urllc.bits_max], n_u,1);

arrivals.embb_bits = embb_bits;
arrivals.urllc_bits = urllc_bits;

end