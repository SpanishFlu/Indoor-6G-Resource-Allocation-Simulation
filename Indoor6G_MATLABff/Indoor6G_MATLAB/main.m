%% ========================================================================
%  Indoor 6G Factory Resource Allocation Simulation — MATLAB
%  ========================================================================
%  Converted from Python Jupyter Notebook + Integrated Waveform Dataset
%  Generation (3GPP TR 38.901 Indoor Factory physically-derived features).
%
%  Pipeline:
%    1. Load configuration
%    2. Build scenario trace (mobility, channel, traffic)
%    3. Run RR / PF / Deadline schedulers
%    4. Summarize KPIs
%    5. Generate waveform_dataset.csv from simulation physics
%    6. Generate all plots
%  ========================================================================

clear; clc; close all;

% Add all subfolders to path
addpath('mobility', 'channel', 'traffic', 'queue', 'scheduler', ...
        'simulation', 'kpi', 'plots', 'dataset');

%% 1) Load configuration
CFG = config();
fprintf('n_slots=%d, n_bs=%d, n_robots=%d\n', CFG.n_slots, CFG.n_bs, CFG.n_robots);
fprintf('deadlines (slots): embb=%d, urllc=%d\n', ...
    CFG.traffic.embb.deadline_slots, CFG.traffic.urllc.deadline_slots);
fprintf('Dataset N_users per snapshot: %d\n', CFG.dataset_N_users);
fprintf('Service probs: P(eMBB)=%.2f, P(URLLC)=%.2f, P(mMTC)=%.2f\n', ...
    CFG.P_eMBB, CFG.P_URLLC, CFG.P_mMTC);

%% 2) Build reproducible scenario trace
rng(CFG.seed);
trace = build_scenario_trace(CFG);

fprintf('LOS fraction in generated trace: %.4f\n', mean(trace.los(:)));

%% 3) Run simulations for each scheduler
fprintf('\nRunning RR scheduler...\n');
rng(CFG.seed + 1);
rr_stats = run_simulation(CFG, trace, 'rr');

fprintf('Running PF scheduler...\n');
rng(CFG.seed + 1);
pf_stats = run_simulation(CFG, trace, 'pf');

fprintf('Running Deadline scheduler...\n');
rng(CFG.seed + 1);
deadline_stats = run_simulation(CFG, trace, 'deadline');

%% 4) Summarize KPIs
summary_rr       = summarize_stats(rr_stats, CFG);
summary_pf       = summarize_stats(pf_stats, CFG);
summary_deadline = summarize_stats(deadline_stats, CFG);

% Display KPI table
fprintf('\n============ KPI SUMMARY ============\n');
fprintf('%-12s %10s %10s %10s %10s %10s %12s %12s %12s %13s\n', ...
    'Scheduler', 'Offer_Mbps', 'Serv_Mbps', 'Load_Ratio', ...
    'eMBB_succ', 'URLLC_succ', ...
    'eMBB_dly_ms', 'URLLC_dly_ms', 'eMBB_p95_ms', 'URLLC_p95_ms');
summaries = {summary_rr, summary_pf, summary_deadline};
for i = 1:3
    s = summaries{i};
    fprintf('%-12s %10.3f %10.3f %10.3f %10.4f %10.4f %12.2f %12.2f %12.2f %13.2f\n', ...
        s.scheduler, s.offered_Mbps, s.served_Mbps, s.load_ratio, ...
        s.embb_success, s.urllc_success, ...
        s.embb_delay_mean_ms, s.urllc_delay_mean_ms, ...
        s.embb_delay_p95_ms, s.urllc_delay_p95_ms);
end

%% 5) Generate waveform dataset from simulation physics
fprintf('\n');
rng(CFG.seed + 2);  % separate seed for dataset generation randomness
ds_info = build_waveform_dataset(CFG, trace);

%% 6) Generate all plots
%  Simulation plots (layout, distance, backlog, KPI bars)
plot_results(CFG, trace, rr_stats, pf_stats, deadline_stats, ...
             summary_rr, summary_pf, summary_deadline);

%  Dataset plots (class distribution, feature histograms, correlations)
plot_dataset(ds_info);

fprintf('\nSimulation and dataset generation complete.\n');
