clc;
clear;
close all;
% ============================
% 2) Global Configuration
% ============================

CFG = struct();

% simulation timing
CFG.seed = 2026;
CFG.sim_time_s = 60.0;      % total simulation time [s]
CFG.slot_s = 0.05;          % scheduler time step [s] (50 ms)

% factory geometry and topology
CFG.factory_w_m = 30.0;     % factory width [m]
CFG.factory_h_m = 16.0;     % factory height [m]
CFG.n_robots = 3;
CFG.bs_xy_m = [0.5 0.5; 29.5 15.5];   % BS coordinates [m]

% lane-based mobility (2x2 lane grid)
CFG.lanes_x_n = 2;          % number of vertical lanes
CFG.lanes_y_n = 2;          % number of horizontal lanes
CFG.v_min_mps = 0.5;        % minimum robot speed [m/s]
CFG.v_max_mps = 1.2;        % maximum robot speed [m/s]
CFG.lane_switch_prob = 0.03;

% communication / channel parameters
CFG.fc_GHz = 3.5;           
CFG.bandwidth_Hz = 2.0e6;   
CFG.tx_power_dBm = 3.0;     
CFG.noise_figure_dB = 7.0;
CFG.bs_height_m = 4.5;
CFG.robot_height_m = 1.2;
CFG.shadow_sigma_los_dB = 3.0;
CFG.shadow_sigma_nlos_dB = 8.03;

% ============================
% Traffic model
% ============================

CFG.traffic.embb.arrival_prob = 0.30;
CFG.traffic.embb.bits_min = 180000;
CFG.traffic.embb.bits_max = 260000;
CFG.traffic.embb.deadline_s = 1.5;

CFG.traffic.urllc.arrival_prob = 0.25;
CFG.traffic.urllc.bits_min = 1200;
CFG.traffic.urllc.bits_max = 2200;
CFG.traffic.urllc.deadline_s = 0.10;

% scheduler parameters
CFG.pf_alpha = 0.90;
CFG.eps = 1e-9;

% plotting helper
CFG.distance_plot_bs_index = 1;  % MATLAB uses 1-based indexing

% ============================
% Derived values
% ============================

CFG.n_slots = floor(CFG.sim_time_s / CFG.slot_s);
CFG.n_bs = size(CFG.bs_xy_m,1);

% convert deadlines from seconds to integer slots
classes = {'embb','urllc'};

for i = 1:length(classes)
    cls = classes{i};
    deadline_slots = max(1, ceil(CFG.traffic.(cls).deadline_s / CFG.slot_s));
    CFG.traffic.(cls).deadline_slots = deadline_slots;
end

% ============================
% Display results
% ============================

fprintf("n_slots=%d, n_bs=%d, n_robots=%d\n", ...
        CFG.n_slots, CFG.n_bs, CFG.n_robots);

fprintf("deadlines (slots): embb=%d, urllc=%d\n", ...
        CFG.traffic.embb.deadline_slots, ...
        CFG.traffic.urllc.deadline_slots);
trace = build_scenario_trace(CFG);

disp("trace keys:");
disp(fieldnames(trace));

disp("distance tensor [T,B,U] shape:");
disp(size(trace.d2d));

los_fraction = mean(trace.los(:));

fprintf("LOS fraction in generated trace: %.6f\n", los_fraction);
% rebuild trace
trace = build_scenario_trace(CFG);

% run simulations
rr_stats       = run_simulation(CFG, trace, 'rr');
pf_stats       = run_simulation(CFG, trace, 'pf');
deadline_stats = run_simulation(CFG, trace, 'deadline');

% summarize KPIs
kpi_rr       = summarize_stats(rr_stats, CFG);
kpi_pf       = summarize_stats(pf_stats, CFG);
kpi_deadline = summarize_stats(deadline_stats, CFG);

% combine into table
kpi_table = struct2table([kpi_rr, kpi_pf, kpi_deadline]);
disp(kpi_table);