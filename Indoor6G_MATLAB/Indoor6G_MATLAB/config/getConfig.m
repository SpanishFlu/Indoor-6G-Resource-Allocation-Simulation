function CFG = getConfig()
%GETCONFIG Global configuration

    % ============================
    % 2) Global Configuration
    % ============================

    CFG = struct();

    % simulation timing
    CFG.seed = 2026;
    CFG.sim_time_s = 60.0;   % total simulation time [s]
    CFG.slot_s = 0.05;       % scheduler time step [s] (50 ms)

    % factory geometry and topology
    CFG.factory_w_m = 30.0;  % factory width [m]
    CFG.factory_h_m = 16.0;  % factory height [m]
    CFG.n_robots = 3;
    CFG.bs_xy_m = [0.5 0.5;
                   29.5 15.5];   % BS coordinates [m]

    % lane-based mobility (2x2 lane grid)
    CFG.lanes_x_n = 2;       % number of vertical lanes
    CFG.lanes_y_n = 2;       % number of horizontal lanes
    CFG.v_min_mps = 0.5;     % minimum robot speed [m/s]
    CFG.v_max_mps = 1.2;     % maximum robot speed [m/s]
    CFG.lane_switch_prob = 0.03;  % per-slot probability

    % communication / channel parameters
    CFG.fc_GHz = 3.5;          % carrier frequency [GHz]
    CFG.bandwidth_Hz = 2.0e6;  % system bandwidth [Hz]
    CFG.tx_power_dBm = 3.0;    % per-link TX power [dBm]
    CFG.noise_figure_dB = 7.0;
    CFG.bs_height_m = 4.5;
    CFG.robot_height_m = 1.2;
    CFG.shadow_sigma_los_dB = 3.0;
    CFG.shadow_sigma_nlos_dB = 8.03;

    % traffic model
    CFG.traffic = struct();

    CFG.traffic.embb = struct( ...
        'arrival_prob', 0.30, ...
        'bits_min', 180000, ...
        'bits_max', 260000, ...
        'deadline_s', 1.5);

    CFG.traffic.urllc = struct( ...
        'arrival_prob', 0.25, ...
        'bits_min', 1200, ...
        'bits_max', 2200, ...
        'deadline_s', 0.10);

    % scheduler parameters
    CFG.pf_alpha = 0.90;
    CFG.eps = 1e-9;

    % plotting helper
    % MATLAB uses 1-based indexing, so BS 0 in Python becomes 1 here
    CFG.distance_plot_bs_index = 1;

    % derived values
    CFG.n_slots = floor(CFG.sim_time_s / CFG.slot_s);
    CFG.n_bs = size(CFG.bs_xy_m, 1);

    % convert deadlines from seconds to integer slots
    classes = {'embb', 'urllc'};
    for i = 1:numel(classes)
        cls = classes{i};
        CFG.traffic.(cls).deadline_slots = ...
            max(1, ceil(CFG.traffic.(cls).deadline_s / CFG.slot_s));
    end
end