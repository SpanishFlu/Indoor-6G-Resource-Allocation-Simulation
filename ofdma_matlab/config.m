function CFG = config()
% CONFIG  Indoor 6G Factory OFDMA Simulation — all parameters.

    % ── Simulation timing ────────────────────────────────────────────────
    CFG.seed         = 2026;
    CFG.sim_time_s   = 60.0;
    CFG.slot_s       = 0.05;

    % ── Factory geometry ─────────────────────────────────────────────────
    CFG.factory_w_m  = 30.0;
    CFG.factory_h_m  = 16.0;
    CFG.n_robots     = 3;
    CFG.bs_xy_m      = [0.5, 0.5; 29.5, 15.5];
    CFG.bs_height_m  = 4.5;
    CFG.robot_height_m = 1.2;

    % ── Lane-based mobility ──────────────────────────────────────────────
    CFG.lanes_x_n      = 2;
    CFG.lanes_y_n      = 2;
    CFG.v_min_mps      = 0.5;
    CFG.v_max_mps      = 1.2;
    CFG.lane_switch_prob = 0.03;

    % ── OFDMA ────────────────────────────────────────────────────────────
    CFG.bandwidth_Hz       = 2.0e6;
    CFG.subcarrier_spacing = 15e3;     % 15 kHz
    CFG.n_rb               = 10;       % Resource Blocks
    CFG.symbols_per_slot   = 14;
    CFG.subcarriers_per_rb = 12;

    % ── Channel ──────────────────────────────────────────────────────────
    CFG.fc_GHz               = 3.5;
    CFG.tx_power_dBm         = 3.0;
    CFG.noise_figure_dB      = 7.0;
    CFG.shadow_sigma_los_dB  = 3.0;
    CFG.shadow_sigma_nlos_dB = 8.03;
    CFG.c_light              = 3e8;

    % ── Traffic ──────────────────────────────────────────────────────────
    CFG.traffic.embb.arrival_prob  = 0.30;
    CFG.traffic.embb.bits_min      = 180000;
    CFG.traffic.embb.bits_max      = 260000;
    CFG.traffic.embb.deadline_s    = 1.5;

    CFG.traffic.urllc.arrival_prob = 0.25;
    CFG.traffic.urllc.bits_min     = 1200;
    CFG.traffic.urllc.bits_max     = 2200;
    CFG.traffic.urllc.deadline_s   = 0.10;

    % ── Scheduler ────────────────────────────────────────────────────────
    CFG.pf_alpha = 0.90;
    CFG.eps      = 1e-9;

    % ── 3GPP TR 38.901 delay spread ──────────────────────────────────────
    CFG.mu_lgDS    = -7.49;
    CFG.sigma_lgDS =  0.43;

    % ── Service-aware velocity ranges [km/h] ─────────────────────────────
    CFG.v_embb_max_kmh  = 120;
    CFG.v_urllc_max_kmh =  30;
    CFG.v_mmtc_max_kmh  =   5;

    % ── Service probabilities ────────────────────────────────────────────
    CFG.P_eMBB  = 0.25;
    CFG.P_URLLC = 0.50;
    CFG.P_mMTC  = 0.25;

    % ── Dataset ──────────────────────────────────────────────────────────
    CFG.dataset_N_users = 20;
    CFG.class_counts    = [1457, 1359, 1583, 1734, 1329, ...
                           1187, 1298, 1329, 1492, 1835];

    % ── Plotting helper ──────────────────────────────────────────────────
    CFG.distance_plot_bs_index = 1;

    % ── Derived values ───────────────────────────────────────────────────
    CFG.n_slots = floor(CFG.sim_time_s / CFG.slot_s);
    CFG.n_bs    = size(CFG.bs_xy_m, 1);

    % Thermal noise floor
    CFG.noise_dBm = -174.0 + 10.0*log10(CFG.bandwidth_Hz) + CFG.noise_figure_dB;

    % RB bandwidth
    CFG.rb_bw_hz = CFG.subcarrier_spacing * CFG.subcarriers_per_rb;

    % Deadline in slots
    classes = {'embb','urllc'};
    for ic = 1:2
        cls = classes{ic};
        CFG.traffic.(cls).deadline_slots = max(1, ...
            ceil(CFG.traffic.(cls).deadline_s / CFG.slot_s));
    end
end
