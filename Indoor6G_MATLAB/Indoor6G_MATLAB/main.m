%% Indoor 6G Resource Allocation Simulation
clc;
clear;
close all;

% Add project folders to MATLAB path
projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

CFG = getConfig();
rng(CFG.seed);

fprintf('n_slots=%d, n_bs=%d, n_robots=%d\n', ...
    CFG.n_slots, CFG.n_bs, CFG.n_robots);

fprintf('deadlines (slots): {''embb'': %d, ''urllc'': %d}\n', ...
    CFG.traffic.embb.deadline_slots, ...
    CFG.traffic.urllc.deadline_slots);

%% Mobility trace
[x_lanes, y_lanes] = generateLanes(CFG);
robots = initRobots(CFG, x_lanes, y_lanes);

pos = zeros(CFG.n_slots, CFG.n_robots, 2);
pos(1, :, :) = robots.pos;

for t = 2:CFG.n_slots
    [robots, pos_t] = updateRobotPositions(CFG, robots, x_lanes, y_lanes);
    pos(t, :, :) = pos_t;
end

%% Distance trace
d2d = computeDistance(pos, CFG.bs_xy_m);
dh = CFG.bs_height_m - CFG.robot_height_m;
d3d = sqrt(d2d.^2 + dh.^2);

%% LOS / Path loss trace
p_los = isLOS(d2d);
los = rand(CFG.n_slots, CFG.n_bs, CFG.n_robots) < p_los;

pl_dB = computePathLoss(d3d, CFG.fc_GHz, los);

shadow_sigma = CFG.shadow_sigma_nlos_dB * ones(size(los));
shadow_sigma(los) = CFG.shadow_sigma_los_dB;
pl_dB = pl_dB + shadow_sigma .* randn(size(pl_dB));

%% SNR / Rate trace
[rx_dBm, noise_dBm, ~, rate_no_int_bps] = computeSINR(CFG, pl_dB);

%% Traffic arrivals
arrivals = generateTraffic(CFG);

%% Scenario trace
trace = struct();
trace.pos = pos;
trace.d2d = d2d;
trace.d3d = d3d;
trace.los = los;
trace.pl_dB = pl_dB;
trace.rx_dBm = rx_dBm;
trace.noise_dBm = noise_dBm;
trace.rate_no_int_bps = rate_no_int_bps;
trace.arrivals = arrivals;

fprintf('trace keys: {''pos'', ''d2d'', ''d3d'', ''los'', ''pl_dB'', ''rx_dBm'', ''noise_dBm'', ''rate_no_int_bps'', ''arrivals''}\n');
fprintf('distance tensor [T,B,U] shape: (%d, %d, %d)\n', size(trace.d2d,1), size(trace.d2d,2), size(trace.d2d,3));
fprintf('LOS fraction in generated trace: %.16f\n', mean(trace.los(:)));

%% Run simulations
rr_stats = updateMetrics(CFG, trace, 'rr');
pf_stats = updateMetrics(CFG, trace, 'pf');
deadline_stats = updateMetrics(CFG, trace, 'deadline');

%% Summarize KPIs
kpi_rr = summarizeResults(rr_stats, CFG);
kpi_pf = summarizeResults(pf_stats, CFG);
kpi_deadline = summarizeResults(deadline_stats, CFG);

kpi_table = struct2table([kpi_rr; kpi_pf; kpi_deadline]);
disp(kpi_table);
plotFactory(CFG, trace);
plotDistances(CFG, trace);
plotResults(CFG, rr_stats, pf_stats, deadline_stats, kpi_table);