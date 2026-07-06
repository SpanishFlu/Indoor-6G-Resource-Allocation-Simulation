%% ========================================================================
%  Indoor 6G Factory Resource Allocation Simulation — MATLAB
%  ========================================================================
%  Converted from Python Jupyter Notebook + Integrated Waveform Dataset
%  Generation (3GPP TR 38.901 Indoor Factory physically-derived features).
%
%  This variant: mMTC removed (eMBB/URLLC-only system), robots dedicated
%  1 eMBB : 2 URLLC, and the PF scheduler uses a classification-derived
%  effective bandwidth (numerology + guard band), compared before/after.
%
%  Pipeline:
%    1. Load configuration
%    2. Build scenario trace (mobility, channel, traffic)
%    3. Run RR / PF(before) / PF(after) / Deadline schedulers
%    4. Summarize KPIs + PF before/after comparison
%    5. Generate waveform_dataset.csv from simulation physics
%    5b. Reference data-rate lookup table per waveform class
%    6. Generate all plots (incl. PF before/after KPI comparison)
%  ========================================================================

clear; clc; close all;

% Add all subfolders to path
addpath('mobility', 'channel', 'traffic', 'queue', 'scheduler', ...
        'simulation', 'kpi', 'plots', 'dataset');

%% 1) Load configuration
CFG = config();
fprintf('n_slots=%d, n_bs=%d, n_robots=%d\n', CFG.n_slots, CFG.n_bs, CFG.n_robots);
fprintf('Robot roles: %d eMBB-only, %d URLLC-only\n', CFG.n_embb_robots, CFG.n_urllc_robots);
fprintf('deadlines (slots): embb=%d, urllc=%d\n', ...
    CFG.traffic.embb.deadline_slots, CFG.traffic.urllc.deadline_slots);
fprintf('Dataset N_users per snapshot: %d\n', CFG.dataset_N_users);
fprintf('Service probs (mMTC removed): P(eMBB)=%.3f, P(URLLC)=%.3f\n', ...
    CFG.P_eMBB, CFG.P_URLLC);

%% 2) Build reproducible scenario trace
rng(CFG.seed);
trace = build_scenario_trace(CFG);

fprintf('LOS fraction in generated trace: %.4f\n', mean(trace.los(:)));

%% 2b) Shared ground-truth slot classification (single source of truth)
%  Computed ONCE here so PF's Method A/B and the exported
%  waveform_dataset.csv all use the IDENTICAL per-slot class labels,
%  instead of each independently re-deriving classification with its
%  own random draws.
fprintf('\nClassifying all %d slots (shared ground truth for PF + dataset)...\n', CFG.n_slots);
rng(CFG.seed + 10);
[slot_features, slot_class_id] = classify_all_slots(CFG, trace);

%% 3) Run simulations for each scheduler
fprintf('\nRunning RR scheduler...\n');
rng(CFG.seed + 1);
rr_stats = run_simulation(CFG, trace, 'rr');

fprintf('Running PF scheduler (before: flat system bandwidth)...\n');
rng(CFG.seed + 1);
pf_before_stats = run_simulation(CFG, trace, 'pf', false);

fprintf('Running PF scheduler (after: class-aware effective bandwidth, Method A - Shannon)...\n');
rng(CFG.seed + 1);
pf_after_stats = run_simulation(CFG, trace, 'pf', 'shannon', slot_class_id);

fprintf('Running PF scheduler (after: class-aware effective bandwidth, Method B - RB-based)...\n');
rng(CFG.seed + 1);
pf_after_b_stats = run_simulation(CFG, trace, 'pf', 'rb', slot_class_id);

pf_stats = pf_after_stats;  % used everywhere else "PF" is referenced

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

%% 4b) PF: before vs Method A (Shannon) vs Method B (RB-based)
summary_pf_before = summarize_stats(pf_before_stats, CFG);
summary_pf_after  = summarize_stats(pf_after_stats,  CFG);
summary_pf_after_b = summarize_stats(pf_after_b_stats, CFG);

mean_bw_before_Hz = mean(pf_before_stats.slot_bw_eff_Hz);   % == CFG.bandwidth_Hz
mean_bw_after_Hz  = mean(pf_after_stats.slot_bw_eff_Hz);
mean_bw_after_b_Hz = mean(pf_after_b_stats.slot_bw_eff_Hz);  % same BW_eff basis as Method A (used to derive N_RB)
util_after_pct    = 100 * mean_bw_after_Hz / CFG.bandwidth_Hz;
util_after_b_pct  = 100 * mean_bw_after_b_Hz / CFG.bandwidth_Hz;

fprintf('\n============ PF: BEFORE vs METHOD A (Shannon) vs METHOD B (RB-based) ============\n');
fprintf('%-30s %15s %15s %15s\n', 'Metric', 'Before', 'Method A', 'Method B');
fprintf('%-30s %15.3f %15.3f %15.3f\n', 'Mean eff. bandwidth [MHz]', mean_bw_before_Hz/1e6, mean_bw_after_Hz/1e6, mean_bw_after_b_Hz/1e6);
fprintf('%-30s %15s %14.1f%% %14.1f%%\n', 'Bandwidth utilization', '100.0%', util_after_pct, util_after_b_pct);
fprintf('%-30s %15.3f %15.3f %15.3f\n', 'Served throughput [Mbps]', summary_pf_before.served_Mbps, summary_pf_after.served_Mbps, summary_pf_after_b.served_Mbps);
fprintf('%-30s %15.3f %15.3f %15.3f\n', 'Load ratio', summary_pf_before.load_ratio, summary_pf_after.load_ratio, summary_pf_after_b.load_ratio);
fprintf('%-30s %15.4f %15.4f %15.4f\n', 'eMBB success rate', summary_pf_before.embb_success, summary_pf_after.embb_success, summary_pf_after_b.embb_success);
fprintf('%-30s %15.4f %15.4f %15.4f\n', 'URLLC success rate', summary_pf_before.urllc_success, summary_pf_after.urllc_success, summary_pf_after_b.urllc_success);
fprintf('%-30s %15.2f %15.2f %15.2f\n', 'eMBB mean delay [ms]', summary_pf_before.embb_delay_mean_ms, summary_pf_after.embb_delay_mean_ms, summary_pf_after_b.embb_delay_mean_ms);
fprintf('%-30s %15.2f %15.2f %15.2f\n', 'URLLC mean delay [ms]', summary_pf_before.urllc_delay_mean_ms, summary_pf_after.urllc_delay_mean_ms, summary_pf_after_b.urllc_delay_mean_ms);
fprintf('%-30s %15.2f %15.2f %15.2f\n', 'eMBB p95 delay [ms]', summary_pf_before.embb_delay_p95_ms, summary_pf_after.embb_delay_p95_ms, summary_pf_after_b.embb_delay_p95_ms);
fprintf('%-30s %15.2f %15.2f %15.2f\n', 'URLLC p95 delay [ms]', summary_pf_before.urllc_delay_p95_ms, summary_pf_after.urllc_delay_p95_ms, summary_pf_after_b.urllc_delay_p95_ms);

change_a_pct = 100 * (summary_pf_after.served_Mbps   - summary_pf_before.served_Mbps) / max(summary_pf_before.served_Mbps, CFG.eps);
change_b_pct = 100 * (summary_pf_after_b.served_Mbps - summary_pf_before.served_Mbps) / max(summary_pf_before.served_Mbps, CFG.eps);
fprintf('\nThroughput change vs before -- Method A: %+.2f%%,  Method B: %+.2f%%\n', change_a_pct, change_b_pct);

%% 5) Generate waveform dataset from simulation physics
fprintf('\n');
rng(CFG.seed + 2);  % seed for the synthetic-oversampling part only
ds_info = build_waveform_dataset(CFG, trace, slot_features, slot_class_id);

%% 5b) Reference data rate per waveform class (numerology x guard band)
class_rate_table = build_class_rate_table(CFG, trace);

fprintf('\n============ CLASS -> DATA RATE LOOKUP TABLE ============\n');
disp(class_rate_table);

writetable(class_rate_table, 'class_data_rates.csv');
fprintf('Class data rate table exported: class_data_rates.csv\n');

%% 5c) Per-service (eMBB/URLLC) user data rate per class (RB-based, 3GPP-style)
class_user_rate_table = build_class_user_rate_table(CFG);

fprintf('\n============ PER-CLASS: eMBB USER vs URLLC USER DATA RATE ============\n');
disp(class_user_rate_table);

writetable(class_user_rate_table, 'class_user_data_rates.csv');
fprintf('Per-service user rate table exported: class_user_data_rates.csv\n');

%% 6) Generate all plots
%  Simulation plots (layout, distance, backlog, KPI bars)
plot_results(CFG, trace, rr_stats, pf_stats, deadline_stats, ...
             summary_rr, summary_pf, summary_deadline);

%  PF before/after class-aware bandwidth KPI comparison (Before / Method A / Method B)
plot_pf_before_after(summary_pf_before, summary_pf_after, summary_pf_after_b, ...
                      mean_bw_before_Hz, mean_bw_after_Hz, mean_bw_after_b_Hz);

%  Dataset plots (class distribution, feature histograms, correlations)
plot_dataset(ds_info);

fprintf('\nSimulation and dataset generation complete.\n');
