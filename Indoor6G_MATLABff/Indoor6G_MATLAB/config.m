function CFG = config()
% CONFIG  Global configuration for Indoor 6G Factory simulation.
%   Returns a struct with all parameters matching the Python CFG dictionary.

    % ----- simulation timing -----
    CFG.seed           = 2026;
    CFG.sim_time_s     = 60.0;      % total simulation time [s]
    CFG.slot_s         = 0.05;      % scheduler time step [s] (50 ms)

    % ----- factory geometry -----
    CFG.factory_w_m    = 30.0;      % factory width [m]
    CFG.factory_h_m    = 16.0;      % factory height [m]
    CFG.n_robots       = 3;
    CFG.bs_xy_m        = [0.5, 0.5; 29.5, 15.5];  % BS coordinates [m] (n_bs x 2)

    % ----- lane-based mobility (2x2 lane grid) -----
    CFG.lanes_x_n      = 2;         % number of vertical lanes
    CFG.lanes_y_n      = 2;         % number of horizontal lanes
    CFG.v_min_mps      = 0.5;       % minimum robot speed [m/s]
    CFG.v_max_mps      = 1.2;       % maximum robot speed [m/s]
    CFG.lane_switch_prob = 0.03;    % per-slot probability of lane switch

    % ----- communication / channel parameters -----
    CFG.fc_GHz             = 3.5;       % carrier frequency [GHz]
    CFG.bandwidth_Hz       = 2.0e6;     % system bandwidth [Hz]
    CFG.tx_power_dBm       = 3.0;       % per-link TX power [dBm]
    CFG.noise_figure_dB    = 7.0;
    CFG.bs_height_m        = 4.5;
    CFG.robot_height_m     = 1.2;
    CFG.shadow_sigma_los_dB  = 3.0;     % shadowing std for LOS [dB]
    CFG.shadow_sigma_nlos_dB = 8.03;    % shadowing std for NLOS [dB]

    % ----- traffic model (Bernoulli packet arrivals per slot) -----
    CFG.traffic.embb.arrival_prob  = 0.30;
    CFG.traffic.embb.bits_min      = 180000;
    CFG.traffic.embb.bits_max      = 260000;
    CFG.traffic.embb.deadline_s    = 1.5;

    CFG.traffic.urllc.arrival_prob = 0.25;
    CFG.traffic.urllc.bits_min     = 1200;
    CFG.traffic.urllc.bits_max     = 2200;
    CFG.traffic.urllc.deadline_s   = 0.10;

    % ----- scheduler parameters -----
    CFG.pf_alpha = 0.90;           % EWMA factor for PF average-rate
    CFG.eps      = 1e-9;           % numerical guard

    % ----- 3GPP TR 38.901 Indoor Factory channel statistics -----
    %   Table 7.5-6: delay spread log-normal parameters
    CFG.mu_lgDS    = -7.49;        % mean of log10(DS) [s]
    CFG.sigma_lgDS =  0.43;        % std  of log10(DS) [s]
    CFG.c_light    = 3e8;          % speed of light [m/s]

    % ----- Service-aware velocity ranges [km/h] -----
    CFG.v_embb_max_kmh  = 120;    % eMBB: pedestrians + vehicles
    CFG.v_urllc_max_kmh =  30;    % URLLC: industrial robots
    CFG.v_mmtc_max_kmh  =   5;    % mMTC: quasi-static IoT sensors

    % ----- Indoor Factory service probabilities -----
    CFG.P_eMBB  = 0.25;
    CFG.P_URLLC = 0.50;
    CFG.P_mMTC  = 0.25;

    % ----- Dataset generation: N_users per snapshot -----
    CFG.dataset_N_users = 20;      % users per TP snapshot

    % ----- Target class distribution for balanced dataset -----
    CFG.class_counts = [1457, 1359, 1583, 1734, 1329, ...
                        1187, 1298, 1329, 1492, 1835];

    % ----- plotting helper -----
    CFG.distance_plot_bs_index = 1;  % 1-based BS index for distance plot

    % ----- derived values -----
    CFG.n_slots = floor(CFG.sim_time_s / CFG.slot_s);
    CFG.n_bs    = size(CFG.bs_xy_m, 1);

    % convert deadlines from seconds to integer slots
    classes = {'embb', 'urllc'};
    for ic = 1:length(classes)
        cls = classes{ic};
        CFG.traffic.(cls).deadline_slots = max(1, ...
            ceil(CFG.traffic.(cls).deadline_s / CFG.slot_s));
    end
end
