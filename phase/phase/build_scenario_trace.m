function trace = build_scenario_trace(cfg)

rng(cfg.seed);

T = cfg.n_slots;
B = cfg.n_bs;
U = cfg.n_robots;

% robot mobility
pos = simulate_robot_positions(cfg);

% BS coordinates
bs_xy = cfg.bs_xy_m;

% 2D distances
d2d = compute_distances(pos, bs_xy);

% height difference
dh = cfg.bs_height_m - cfg.robot_height_m;

% 3D distance
d3d = sqrt(d2d.^2 + dh.^2);

% LOS probability
p_los = los_probability_inh_office(d2d);

% random LOS realization
los = rand(T,B,U) < p_los;

% pathloss
pl = pathloss_inh_office_dB(d3d, cfg.fc_GHz, los);

% shadowing
shadow_sigma = zeros(size(pl));
shadow_sigma(los==1) = cfg.shadow_sigma_los_dB;
shadow_sigma(los==0) = cfg.shadow_sigma_nlos_dB;

pl = pl + randn(size(pl)) .* shadow_sigma;

% noise power
noise_dBm = thermal_noise_dBm(cfg.bandwidth_Hz, cfg.noise_figure_dB);

% received power
rx_dBm = cfg.tx_power_dBm - pl;

% SNR
snr_dB = rx_dBm - noise_dBm;

% achievable rate
rate_no_int = cfg.bandwidth_Hz .* log2(1 + 10.^(snr_dB/10));

% packet arrivals
arrivals = build_arrival_trace(cfg);

% store trace
trace.pos = pos;
trace.d2d = d2d;
trace.d3d = d3d;
trace.los = los;
trace.pl_dB = pl;
trace.rx_dBm = rx_dBm;
trace.noise_dBm = noise_dBm;
trace.rate_no_int_bps = rate_no_int;
trace.arrivals = arrivals;

end