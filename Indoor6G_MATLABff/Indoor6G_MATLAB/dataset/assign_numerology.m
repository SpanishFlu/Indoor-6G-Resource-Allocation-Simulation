function numerology = assign_numerology(n_eMBB, n_uRLLC, n_mMTC, mean_doppler)
% ASSIGN_NUMEROLOGY  5G NR numerology selection based on service mix and Doppler.
%
%   Thresholds are scaled for a physically-derived N_users=20 user pool
%   with service probabilities P(eMBB)=0.25, P(URLLC)=0.50, P(mMTC)=0.25.
%
%   The original agenerate_set.m used randi([0,50]) independently per type
%   and rand()*500 for Doppler.  Proportional rescaling:
%     User thresholds:  original_threshold / original_max * N_users
%     Doppler thresholds: original / 500 * physical_max (~164 Hz)
%
%   Original → Scaled mapping:
%     n_URLLC > 25   →  n_URLLC > 13    (URLLC-dominated snapshot)
%     n_URLLC > 15   →  n_URLLC > 10
%     doppler > 300  →  doppler > 120
%     n_eMBB  > 35   →  n_eMBB  > 9     (eMBB-dominated snapshot)
%     n_eMBB  > 25   →  n_eMBB  > 7
%     doppler > 200  →  doppler > 80
%     n_mMTC  > 60   →  n_mMTC  > 12    (mMTC-dominated snapshot)
%     n_mMTC  > 40   →  n_mMTC  > 8
%     doppler < 150  →  doppler < 60
%
%   NUM-4 (120 kHz): URLLC-dominated cell or high Doppler + strong URLLC
%   NUM-3 ( 60 kHz): eMBB-dominated cell or moderate Doppler + strong eMBB
%   NUM-2 ( 30 kHz): mMTC-dominated cell (IoT/sensor-heavy)
%   NUM-1 ( 15 kHz): default / balanced traffic

    if n_uRLLC > 13 || (mean_doppler > 120 && n_uRLLC > 10)
        numerology = 4;
    elseif n_eMBB > 9 || (mean_doppler > 80 && n_eMBB > 7)
        numerology = 3;
    elseif n_mMTC > 12 || (n_mMTC > 8 && mean_doppler < 60)
        numerology = 2;
    else
        numerology = 1;
    end
end
