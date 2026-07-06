function trace = build_scenario_trace(cfg)
% BUILD_SCENARIO_TRACE  Generate all pre-computed scenario data.
%   trace = build_scenario_trace(cfg)
%   Includes: positions, distances, LOS, pathloss, rates, arrivals.

    T = cfg.n_slots;
    B = cfg.n_bs;
    U = cfg.n_robots;

    % --- Mobility ---
    pos = simulate_robot_positions(cfg);  % (T, U, 2)

    % --- Distances (T, B, U) ---
    bs_xy = cfg.bs_xy_m;  % (B, 2)
    d2d = zeros(T, B, U);
    for b = 1:B
        dx = pos(:, :, 1) - bs_xy(b, 1);  % (T, U)
        dy = pos(:, :, 2) - bs_xy(b, 2);  % (T, U)
        d2d(:, b, :) = sqrt(dx.^2 + dy.^2);
    end

    dh  = cfg.bs_height_m - cfg.robot_height_m;
    d3d = sqrt(d2d.^2 + dh^2);

    % --- LOS probability and realization ---
    p_los = los_probability_inh_office(d2d);
    los   = rand(T, B, U) < p_los;  % logical

    % --- Pathloss with shadowing ---
    pl = pathloss_inh_office_dB(d3d, cfg.fc_GHz, los);
    shadow_sigma = cfg.shadow_sigma_nlos_dB * ones(T, B, U);
    shadow_sigma(los) = cfg.shadow_sigma_los_dB;
    pl = pl + randn(T, B, U) .* shadow_sigma;

    % --- SNR and interference-free rate ---
    noise_dBm = -174.0 + 10.0 * log10(cfg.bandwidth_Hz) + cfg.noise_figure_dB;
    rx_dBm    = cfg.tx_power_dBm - pl;
    snr_dB    = rx_dBm - noise_dBm;
    rate_no_int = cfg.bandwidth_Hz * log2(1.0 + 10.^(snr_dB / 10.0));

    % --- Traffic arrivals ---
    arrivals = build_arrival_trace(cfg);

    % --- Pack trace struct ---
    trace.pos              = pos;
    trace.d2d              = d2d;
    trace.d3d              = d3d;
    trace.los              = los;
    trace.pl_dB            = pl;
    trace.rx_dBm           = rx_dBm;
    trace.noise_dBm        = noise_dBm;
    trace.rate_no_int_bps  = rate_no_int;
    trace.arrivals         = arrivals;
end
