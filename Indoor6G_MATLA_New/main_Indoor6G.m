%% ============================================================
%%  main_Indoor6G.m
%%  Indoor 6G Resource Allocation Simulation (Phase 2)
%%  Indoor Factory Robot Scenario — Corrected to match Python reference
%% ============================================================
clc; clear; close all;

% Add project folders to MATLAB path
projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

%% 1. Configuration
CFG = getConfig();
rng(CFG.seed);

fprintf('n_slots=%d, n_bs=%d, n_robots=%d\n', ...
    CFG.n_slots, CFG.n_bs, CFG.n_robots);
fprintf('deadlines (slots): {''embb'': %d, ''urllc'': %d}\n', ...
    CFG.traffic.embb.deadline_slots, ...
    CFG.traffic.urllc.deadline_slots);

%% 2. Mobility trace
[x_lanes, y_lanes] = generateLanes(CFG);
robots = initRobots(CFG, x_lanes, y_lanes);
pos = zeros(CFG.n_slots, CFG.n_robots, 2);
pos(1, :, :) = robots.pos;

for t = 2:CFG.n_slots
    [robots, pos_t] = updateRobotPositions(CFG, robots, x_lanes, y_lanes);
    pos(t, :, :) = pos_t;
end

%% 3. Channel trace (distance, LOS, path loss, SINR)
d2d = computeDistance(pos, CFG.bs_xy_m);
dh  = CFG.bs_height_m - CFG.robot_height_m;
d3d = sqrt(d2d.^2 + dh.^2);

p_los = isLOS(d2d);
los   = rand(CFG.n_slots, CFG.n_bs, CFG.n_robots) < p_los;

pl_dB = computePathLoss(d3d, CFG.fc_GHz, los);
shadow_sigma = CFG.shadow_sigma_nlos_dB * ones(size(los));
shadow_sigma(los) = CFG.shadow_sigma_los_dB;
pl_dB = pl_dB + shadow_sigma .* randn(size(pl_dB));

[rx_dBm, noise_dBm, ~, rate_no_int_bps] = computeSINR(CFG, pl_dB);

%% 4. Traffic arrivals (all robots get BOTH eMBB and URLLC)
arrivals = generateTraffic(CFG);

%% 5. Pack scenario trace
trace.pos             = pos;
trace.d2d             = d2d;
trace.d3d             = d3d;
trace.los             = los;
trace.pl_dB           = pl_dB;
trace.rx_dBm          = rx_dBm;
trace.noise_dBm       = noise_dBm;
trace.rate_no_int_bps = rate_no_int_bps;
trace.arrivals        = arrivals;

fprintf('distance tensor [T,B,U] shape: (%d, %d, %d)\n', ...
    size(d2d,1), size(d2d,2), size(d2d,3));
fprintf('LOS fraction: %.6f\n', mean(los(:)));

%% 6. Run schedulers
rr_stats       = runSimulation(CFG, trace, 'rr');
pf_stats       = runSimulation(CFG, trace, 'pf');
deadline_stats = runSimulation(CFG, trace, 'deadline');

%% 7. KPI summary
kpi_rr       = summarizeResults(rr_stats,       CFG);
kpi_pf       = summarizeResults(pf_stats,       CFG);
kpi_deadline = summarizeResults(deadline_stats, CFG);

kpi_table = struct2table([kpi_rr; kpi_pf; kpi_deadline]);
disp(kpi_table);

%% 8. Plots
plotFactory(CFG, trace);
plotDistances(CFG, trace);
plotResults(CFG, rr_stats, pf_stats, deadline_stats, kpi_table);
