function CFG = getConfig()
%GETCONFIG  Global simulation parameters.
%   Corrected: removed robot_type / n_embb / n_urllc so every robot
%   receives BOTH eMBB and URLLC traffic (matching the Python reference).

    CFG.seed             = 2026;
    CFG.sim_time_s       = 60.0;
    CFG.slot_s           = 0.05;

    % Factory geometry
    CFG.factory_w_m      = 30.0;
    CFG.factory_h_m      = 16.0;
    CFG.n_robots         = 3;

    % BS positions
    CFG.bs_xy_m = [0.5, 0.5;
                   CFG.factory_w_m - 0.5, CFG.factory_h_m - 0.5];

    % Lane-based mobility
    CFG.lanes_x_n        = 2;
    CFG.lanes_y_n        = 2;
    CFG.v_min_mps        = 0.5;
    CFG.v_max_mps        = 1.2;
    CFG.lane_switch_prob = 0.03;

    % Channel
    CFG.fc_GHz           = 3.5;
    CFG.bandwidth_Hz     = 2.0e6;
    CFG.tx_power_dBm     = 3.0;
    CFG.noise_figure_dB  = 7.0;
    CFG.bs_height_m      = 4.5;
    CFG.robot_height_m   = 1.2;
    CFG.shadow_sigma_los_dB  = 3.0;
    CFG.shadow_sigma_nlos_dB = 8.03;

    % Traffic
    CFG.traffic.embb.arrival_prob  = 0.30;
    CFG.traffic.embb.bits_min      = 180000;
    CFG.traffic.embb.bits_max      = 260000;
    CFG.traffic.embb.deadline_s    = 1.5;

    CFG.traffic.urllc.arrival_prob = 0.25;
    CFG.traffic.urllc.bits_min     = 1200;
    CFG.traffic.urllc.bits_max     = 2200;
    CFG.traffic.urllc.deadline_s   = 0.10;

    % Scheduler
    CFG.pf_alpha = 0.90;
    CFG.eps      = 1e-9;

    % Derived
    CFG.n_slots = floor(CFG.sim_time_s / CFG.slot_s);
    CFG.n_bs    = size(CFG.bs_xy_m, 1);

    for cls = {'embb','urllc'}
        c = cls{1};
        CFG.traffic.(c).deadline_slots = ...
            max(1, ceil(CFG.traffic.(c).deadline_s / CFG.slot_s));
    end
end
