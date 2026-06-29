function [feat, class_id] = generate_physical_snapshot(cfg)
% GENERATE_PHYSICAL_SNAPSHOT  Create one snapshot using the full 3GPP pipeline.
%   [feat, class_id] = generate_physical_snapshot(cfg)
%
%   Used for oversampling when balancing under-represented classes.
%   Follows the identical physical derivation as extract_slot_features
%   but without requiring a simulation trace (standalone generation).

    Nu = cfg.dataset_N_users;
    fc = cfg.fc_GHz * 1e9;
    c  = cfg.c_light;

    % ----- Service assignment from same user pool -----
    r_svc   = rand(Nu, 1);
    service = zeros(Nu, 1);  % 1=eMBB, 2=URLLC, 3=mMTC
    service(r_svc <  cfg.P_eMBB)                                  = 1;
    service(r_svc >= cfg.P_eMBB & r_svc < cfg.P_eMBB + cfg.P_URLLC) = 2;
    service(r_svc >= cfg.P_eMBB + cfg.P_URLLC)                    = 3;

    N_eMBB  = sum(service == 1);
    N_URLLC = sum(service == 2);
    N_mMTC  = sum(service == 3);

    % ----- Service-aware velocities -----
    v_kmh = zeros(Nu, 1);
    v_kmh(service == 1) = rand(N_eMBB,  1) * cfg.v_embb_max_kmh;
    v_kmh(service == 2) = rand(N_URLLC, 1) * cfg.v_urllc_max_kmh;
    v_kmh(service == 3) = rand(N_mMTC,  1) * cfg.v_mmtc_max_kmh;
    v_ms = v_kmh / 3.6;

    % ----- Doppler per user -----
    f_D      = v_ms * fc / c;
    mu_D     = mean(f_D);
    sigma2_D = mean((f_D - mu_D).^2);

    % ----- 3GPP delay spread -----
    X_i        = cfg.mu_lgDS + cfg.sigma_lgDS * randn(Nu, 1);
    tau_RMS    = 10.^(X_i);
    k_tau      = 5 + 5 * rand(Nu, 1);
    tau_max_us = k_tau .* tau_RMS * 1e6;
    mu_tau     = mean(tau_max_us);
    sigma2_tau = mean((tau_max_us - mu_tau).^2);

    % ----- Feature vector -----
    feat = [mu_tau, sigma2_tau, mu_D, sigma2_D, N_eMBB, N_URLLC, N_mMTC];

    % ----- Classification -----
    numerology = assign_numerology(N_eMBB, N_URLLC, N_mMTC, mu_D);
    guard_band = assign_guard_band(sigma2_tau);
    class_id   = assign_class(guard_band, numerology);
end
