%% ========================================================================
%  Indoor 6G Factory — OFDMA Resource Allocation Simulation
%  ========================================================================
%  Pipeline:
%    1. Config
%    2. Build scenario trace (mobility, channel, traffic)
%    3. Run RR / PF / Deadline schedulers (OFDMA — 10 RBs)
%    4. KPI summary + CSV export
%    5. Waveform dataset generation
%    6. Plots
%% ========================================================================
clear; clc; close all;

addpath('mobility','channel','traffic','queue','ofdma',...
        'simulation','kpi','plots','dataset');

%% 1. Config
CFG = config();
fprintf('=== Indoor 6G OFDMA Simulation ===\n');
fprintf('n_slots=%d | n_bs=%d | n_robots=%d | n_rb=%d\n', ...
    CFG.n_slots, CFG.n_bs, CFG.n_robots, CFG.n_rb);
fprintf('BW=%.0f MHz | SCS=%.0f kHz | RB_BW=%.0f kHz\n', ...
    CFG.bandwidth_Hz/1e6, CFG.subcarrier_spacing/1e3, CFG.rb_bw_hz/1e3);
fprintf('deadlines: eMBB=%d slots | URLLC=%d slots\n', ...
    CFG.traffic.embb.deadline_slots, CFG.traffic.urllc.deadline_slots);

%% 2. Scenario trace
rng(CFG.seed);
trace = build_scenario_trace(CFG);
fprintf('LOS fraction: %.4f\n', mean(trace.los(:)));

%% 3. Run schedulers
schedulers = {'rr','pf','deadline'};
stats_all  = cell(1,3);
for s = 1:3
    fprintf('\nRunning %s scheduler...\n', upper(schedulers{s}));
    rng(CFG.seed+1);
    stats_all{s} = run_simulation(CFG, trace, schedulers{s});
end
rr_stats=stats_all{1}; pf_stats=stats_all{2}; deadline_stats=stats_all{3};

%% 4. KPI summary
summaries = cell(1,3);
for s = 1:3; summaries{s} = summarize_stats(stats_all{s}, CFG); end
sum_rr=summaries{1}; sum_pf=summaries{2}; sum_dl=summaries{3};

fprintf('\n============ KPI SUMMARY ============\n');
fprintf('%-10s %9s %9s %9s %9s %9s %10s %10s %9s %11s %8s\n',...
    'Sched','Offer_Mbps','Serv_Mbps','Load','eMBB_suc','URLLC_suc',...
    'eMBB_dly','URLLC_dly','Jain','RB_util','');
for s=1:3
    k=summaries{s};
    fprintf('%-10s %9.3f %9.3f %9.3f %9.4f %9.4f %10.2f %10.2f %9.4f %9.4f\n',...
        k.scheduler,k.offered_Mbps,k.served_Mbps,k.load_ratio,...
        k.embb_success,k.urllc_success,...
        k.embb_delay_mean_ms,k.urllc_delay_mean_ms,...
        k.jain_fairness,k.rb_utilization);
end

% Export per-scheduler CSVs
for s=1:3
    k=summaries{s};
    T_kpi=table(k.offered_Mbps,k.served_Mbps,k.load_ratio,...
                k.embb_success,k.urllc_success,...
                k.embb_delay_mean_ms,k.urllc_delay_mean_ms,...
                k.embb_delay_p95_ms,k.urllc_delay_p95_ms,...
                k.jain_fairness,k.rb_utilization,...
        'VariableNames',{'offered_Mbps','served_Mbps','load_ratio',...
                         'embb_success','urllc_success',...
                         'embb_delay_mean_ms','urllc_delay_mean_ms',...
                         'embb_delay_p95_ms','urllc_delay_p95_ms',...
                         'jain_fairness','rb_utilization'});
    fname=sprintf('output/%s_results.csv', upper(k.scheduler));
    writetable(T_kpi, fname);
    fprintf('Saved %s\n', fname);
end

% KPI summary CSV
kpi_table=struct2table([summaries{:}]);
writetable(kpi_table,'output/kpi_summary.csv');
fprintf('Saved output/kpi_summary.csv\n');

%% 5. Waveform dataset
fprintf('\n');
rng(CFG.seed+2);
ds_info = build_waveform_dataset(CFG, trace);
movefile('waveform_dataset.csv','output/waveform_dataset.csv');
fprintf('Saved output/waveform_dataset.csv\n');

%% 6. Plots
plot_results(CFG,trace,rr_stats,pf_stats,deadline_stats,sum_rr,sum_pf,sum_dl);
plot_dataset(ds_info);

fprintf('\n=== Simulation complete. ===\n');
