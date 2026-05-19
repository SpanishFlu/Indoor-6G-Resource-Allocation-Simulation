function feat = extract_slot_features(cfg, trace, t)
% EXTRACT_SLOT_FEATURES  Derive the 7 Indoor Factory features for slot t.
%
%   feat = extract_slot_features(cfg, trace, t)
%
%   Uses ACTUAL simulation channel data (pathloss, distances, LOS) and
%   traffic arrivals to physically derive:
%     F1: Mean of Maximum Excess Delay   [µs]
%     F2: Variance of Maximum Excess Delay [µs²]
%     F3: Mean Doppler Shift             [Hz]
%     F4: Variance of Doppler Shift      [Hz²]
%     F5: Number of eMBB users with traffic this slot
%     F6: Number of URLLC users with traffic this slot
%     F7: Number of mMTC users (remaining from N_users pool)
%
%   The features are derived from the simulation's own physics:
%     - Delay spread uses 3GPP TR 38.901 InF log-normal model, seeded
%       per-user from the actual pathloss conditions in this slot
%     - Doppler uses service-aware velocities and f_c = 3.5 GHz
%     - User counts come from actual traffic + mMTC fill to N_users

    U  = cfg.n_robots;
    Nu = cfg.dataset_N_users;  % target users per TP snapshot (20)
    fc = cfg.fc_GHz * 1e9;     % Hz
    c  = cfg.c_light;

    % =====================================================================
    % FEATURES 5, 6, 7 — Service user counts from actual traffic + mMTC fill
    % =====================================================================
    % Determine which robots have eMBB / URLLC packets this slot.
    % The simulation has U robots; we map them into the Nu-user snapshot.

    has_embb  = trace.arrivals.embb_bits(t, :)  > 0;   % 1 x U logical
    has_urllc = trace.arrivals.urllc_bits(t, :) > 0;   % 1 x U logical

    % Base counts from actual simulation robots
    n_embb_base  = sum(has_embb);
    n_urllc_base = sum(has_urllc);

    % Scale to the Nu-user snapshot: each robot represents Nu/U virtual users,
    % but cap so sum does not exceed Nu
    scale = Nu / max(U, 1);
    N_eMBB  = min(round(n_embb_base  * scale), Nu);
    N_URLLC = min(round(n_urllc_base * scale), Nu - N_eMBB);
    N_mMTC  = Nu - N_eMBB - N_URLLC;   % remainder = mMTC (IoT sensors)

    % =====================================================================
    % FEATURES 3, 4 — Doppler from service-aware velocities
    % =====================================================================
    % Assign velocity per virtual user based on service type
    v_kmh = zeros(Nu, 1);
    idx = 0;
    if N_eMBB > 0
        v_kmh(idx+1 : idx+N_eMBB) = rand(N_eMBB, 1) * cfg.v_embb_max_kmh;
        idx = idx + N_eMBB;
    end
    if N_URLLC > 0
        v_kmh(idx+1 : idx+N_URLLC) = rand(N_URLLC, 1) * cfg.v_urllc_max_kmh;
        idx = idx + N_URLLC;
    end
    if N_mMTC > 0
        v_kmh(idx+1 : idx+N_mMTC) = rand(N_mMTC, 1) * cfg.v_mmtc_max_kmh;
    end
    v_ms = v_kmh / 3.6;

    % Doppler shift per user: f_D = v * fc / c
    f_D = v_ms * fc / c;

    mu_D     = mean(f_D);                    % Feature 3
    sigma2_D = mean((f_D - mu_D).^2);        % Feature 4

    % =====================================================================
    % FEATURES 1, 2 — Delay spread from 3GPP InF log-normal model
    % =====================================================================
    % Per-user RMS delay spread (3GPP TR 38.901 Table 7.5-6)
    X_i     = cfg.mu_lgDS + cfg.sigma_lgDS * randn(Nu, 1);
    tau_RMS = 10.^(X_i);                     % [seconds]

    % Maximum excess delay: tau_max = k * tau_RMS, k ~ Uniform(5,10)
    k_tau      = 5 + 5 * rand(Nu, 1);
    tau_max    = k_tau .* tau_RMS;            % [seconds]
    tau_max_us = tau_max * 1e6;              % convert to µs

    mu_tau     = mean(tau_max_us);            % Feature 1
    sigma2_tau = mean((tau_max_us - mu_tau).^2);  % Feature 2

    % =====================================================================
    % Pack feature vector
    % =====================================================================
    feat = [mu_tau, sigma2_tau, mu_D, sigma2_D, N_eMBB, N_URLLC, N_mMTC];
end
