function T = build_class_user_rate_table(cfg)
% BUILD_CLASS_USER_RATE_TABLE  Per-service (eMBB/URLLC) achievable data
% rate for each of the 10 waveform classes, using the 3GPP NR resource-
% block-based data rate formula (TS 38.306-style):
%
%   DataRate = N_RB * 12 * N_symb * Qm * Rcode * (1-OH) / T_slot(mu)
%
%   where, per the reference numerology table:
%     SCS(mu)     = 2^(mu-1) * 15 kHz            (mu = numerology 1..4)
%     T_slot(mu)  = 1 ms / 2^(mu-1)
%     N_symb      = 14 (symbols per slot, normal CP)
%     N_RB        = floor(BW_eff(class) / (12 * SCS(mu)))
%
%   This answers a DIFFERENT question than build_class_rate_table.m:
%   that one gives one Shannon-capacity number per class (channel-quality
%   driven). This one gives what an eMBB user and a URLLC user would
%   EACH individually get if they held that class's RB pool, using
%   service-appropriate MCS assumptions:
%     - eMBB:  prioritizes throughput -> 256QAM, high code rate, lower OH
%     - URLLC: prioritizes reliability -> conservative 16QAM, low code
%              rate (more redundancy), higher OH (control/HARQ overhead)
%   These Qm/Rcode/OH values are representative assumptions, not
%   3GPP-mandated numbers -- state them as assumptions in your report.

    % ----- Reference numerology table -----
    scs_khz    = [15, 30, 60, 120];              % indexed by numerology 1..4
    t_slot_ms  = [1, 0.5, 0.25, 0.125];           % indexed by numerology 1..4
    n_symb     = 14;                              % symbols per slot (normal CP)

    % ----- Per-service MCS assumptions (shared with run_simulation.m) -----
    embb  = service_mcs_params('embb');
    urllc = service_mcs_params('urllc');

    % ----- Class 1..10 definitions (must match dataset/assign_class.m) -----
    class_defs = { ...
        1, 4, 'Zero';  2, 4, 'Small';  3, 4, 'Large'; ...
        4, 3, 'Zero';  5, 3, 'Small';  6, 3, 'Large'; ...
        7, 2, 'Zero';  8, 2, 'Small';  9, 2, 'Large'; ...
        10, 1, 'Any' };

    N = size(class_defs, 1);
    class_id = zeros(N,1); numerology = zeros(N,1); scs_col = zeros(N,1);
    guard_band = strings(N,1); n_rb = zeros(N,1); t_slot_col = zeros(N,1);
    embb_Mbps = zeros(N,1); urllc_Mbps = zeros(N,1);

    for i = 1:N
        cid = class_defs{i,1};
        mu  = class_defs{i,2};
        gb  = class_defs{i,3};

        frac   = class_bandwidth_fraction(mu, gb);
        bw_eff = cfg.bandwidth_Hz * frac;

        rb_bw_Hz = 12 * scs_khz(mu) * 1e3;
        N_RB     = floor(bw_eff / rb_bw_Hz);
        T_slot_s = t_slot_ms(mu) / 1e3;

        rate_embb_bps  = N_RB * 12 * n_symb * embb.Qm  * embb.Rcode  * (1 - embb.OH)  / T_slot_s;
        rate_urllc_bps = N_RB * 12 * n_symb * urllc.Qm * urllc.Rcode * (1 - urllc.OH) / T_slot_s;

        class_id(i)    = cid;
        numerology(i)  = mu;
        scs_col(i)     = scs_khz(mu);
        guard_band(i)  = gb;
        n_rb(i)        = N_RB;
        t_slot_col(i)  = t_slot_ms(mu);
        embb_Mbps(i)   = rate_embb_bps  / 1e6;
        urllc_Mbps(i)  = rate_urllc_bps / 1e6;
    end

    T = table(class_id, numerology, scs_col, guard_band, n_rb, t_slot_col, ...
              embb_Mbps, urllc_Mbps, 'VariableNames', ...
              {'Class', 'Numerology', 'SCS_kHz', 'GuardBand', ...
               'N_RB', 'T_slot_ms', 'eMBB_Mbps', 'URLLC_Mbps'});

    T = sortrows(T, 'Class');
end
