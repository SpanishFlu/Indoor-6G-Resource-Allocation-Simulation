function T = build_class_rate_table(cfg, trace)
% BUILD_CLASS_RATE_TABLE  Reference "suitable" data rate per waveform class.
%   T = build_class_rate_table(cfg, trace)
%
%   Each of the 10 classes (see dataset/assign_class.m) is a
%   (numerology, guard_band) combination. This assigns each class a
%   representative achievable data rate using the SAME Shannon-capacity
%   formula as the scheduler in simulation/run_simulation.m:
%       rate_bps = BW_eff * log2(1 + SINR)
%   with SINR computed from the same link-budget parameters
%   (tx_power_dBm, noise_figure_dB) and a representative pathloss taken
%   as the median of the actual simulated trace.
%
%   The only thing that changes per class is the EFFECTIVE bandwidth,
%   via the shared class_bandwidth_fraction() helper (numerology's
%   inherent usable-RB fraction x guard-band category's extra overhead).
%   A smaller effective bandwidth both lowers the Shannon BW term AND
%   lowers the thermal noise floor (N = -174dBm/Hz + NF, scaled by BW),
%   so the SINR/rate trade-off is handled consistently, not just bolted on.
%
%   Returns a MATLAB table with one row per class (1..10).

    % ----- Numerology -> subcarrier spacing (for display only; the usable-BW
    %       fraction itself comes from the shared class_bandwidth_fraction
    %       helper so this table and the PF scheduler stay consistent) -----
    scs_khz = [15, 30, 60, 120];        % indexed by numerology 1..4

    % ----- Class 1..10 definitions (must match dataset/assign_class.m) -----
    class_defs = { ...
        1, 4, 'Zero';  2, 4, 'Small';  3, 4, 'Large'; ...
        4, 3, 'Zero';  5, 3, 'Small';  6, 3, 'Large'; ...
        7, 2, 'Zero';  8, 2, 'Small';  9, 2, 'Large'; ...
        10, 1, 'Any' };   % NUM-1 collapses all guard bands into Class 10

    % ----- Representative link condition (same physics as the scheduler) -----
    pl_ref_dB  = median(trace.pl_dB(:));
    tx_power_W = 10^((cfg.tx_power_dBm - 30) / 10);
    signal_W   = tx_power_W * 10^(-pl_ref_dB / 10);

    N = size(class_defs, 1);
    class_id = zeros(N,1); numerology = zeros(N,1); scs_col = zeros(N,1);
    guard_band = strings(N,1); usable_frac = zeros(N,1);
    bw_eff_Hz = zeros(N,1); sinr_dB = zeros(N,1); rate_Mbps = zeros(N,1);

    for i = 1:N
        cid = class_defs{i,1};
        mu  = class_defs{i,2};
        gb  = class_defs{i,3};

        frac   = class_bandwidth_fraction(mu, gb);
        bw_eff = cfg.bandwidth_Hz * frac;

        noise_dBm = -174 + 10*log10(bw_eff) + cfg.noise_figure_dB;
        noise_W   = 10^((noise_dBm - 30) / 10);
        sinr      = signal_W / max(noise_W, cfg.eps);
        rate_bps  = bw_eff * log2(1 + sinr);

        class_id(i)    = cid;
        numerology(i)  = mu;
        scs_col(i)     = scs_khz(mu);
        guard_band(i)  = gb;
        usable_frac(i) = frac;
        bw_eff_Hz(i)   = bw_eff;
        sinr_dB(i)     = 10*log10(sinr);
        rate_Mbps(i)   = rate_bps / 1e6;
    end

    T = table(class_id, numerology, scs_col, guard_band, usable_frac, ...
              bw_eff_Hz, sinr_dB, rate_Mbps, 'VariableNames', ...
              {'Class', 'Numerology', 'SCS_kHz', 'GuardBand', ...
               'UsableBWFrac', 'BW_eff_Hz', 'SINR_dB', 'Rate_Mbps'});

    T = sortrows(T, 'Class');
end
