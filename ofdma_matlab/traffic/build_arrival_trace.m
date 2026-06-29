function arrivals = build_arrival_trace(cfg)
% BUILD_ARRIVAL_TRACE  Bernoulli packet arrivals. Returns arrivals.embb_bits(T,U)
%                      and arrivals.urllc_bits(T,U).
    T=cfg.n_slots; U=cfg.n_robots;
    embb_bits=zeros(T,U); urllc_bits=zeros(T,U);
    embb_mask =rand(T,U)<cfg.traffic.embb.arrival_prob;
    urllc_mask=rand(T,U)<cfg.traffic.urllc.arrival_prob;
    ne=sum(embb_mask(:)); nu=sum(urllc_mask(:));
    embb_bits(embb_mask)  =randi([cfg.traffic.embb.bits_min, cfg.traffic.embb.bits_max],ne,1);
    urllc_bits(urllc_mask)=randi([cfg.traffic.urllc.bits_min,cfg.traffic.urllc.bits_max],nu,1);
    arrivals.embb_bits=embb_bits;
    arrivals.urllc_bits=urllc_bits;
end
