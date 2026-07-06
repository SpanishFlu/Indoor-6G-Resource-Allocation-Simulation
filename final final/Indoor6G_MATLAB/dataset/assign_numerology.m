function numerology = assign_numerology(n_eMBB, n_uRLLC, mean_doppler)
% ASSIGN_NUMEROLOGY  5G NR numerology selection based on service mix and Doppler.
%   numerology = assign_numerology(n_eMBB, n_uRLLC, mean_doppler)
%
%   eMBB/URLLC-only system (mMTC removed). Since every user pool splits
%   exactly N_eMBB + N_uRLLC = N_users (no remainder), thresholds are
%   defined on n_uRLLC directly.
%
%   NOTE ON REACHABILITY: with dedicated robots (1 eMBB : 2 URLLC), real
%   simulation slots only ever produce n_uRLLC in {13, 20} (bimodal —
%   either the one eMBB robot had traffic this slot, or it didn't), while
%   the synthetic oversampling pool (generate_physical_snapshot.m) spans
%   the full 0..20 range. Thresholds below are chosen so BOTH the n_uRLLC
%   = 13 case (real, 30% of slots) and the broader synthetic pool land in
%   NUM-2 some of the time — a strict "doppler < 60" cut left NUM-2
%   (and therefore classes 7/8/9) completely unreachable, since observed
%   mean Doppler across slots is itself centered around ~100 Hz.
%
%   NUM-4 (120 kHz): URLLC-dominated  (n_uRLLC >= 14, i.e. n_eMBB <= 6)
%   NUM-3 ( 60 kHz): eMBB-dominated   (n_uRLLC <= 9,  i.e. n_eMBB >= 11)
%                    [reachable mainly via the synthetic pool — real
%                    slots are capped at n_eMBB<=7 by the single
%                    dedicated eMBB robot]
%   NUM-2 ( 30 kHz): balanced mix, lower mobility (10<=n_uRLLC<=13,
%                    mean_doppler < 100 Hz)
%   NUM-1 ( 15 kHz): balanced mix, higher mobility (10<=n_uRLLC<=13,
%                    mean_doppler >= 100 Hz) — also the default

    if n_uRLLC >= 14
        numerology = 4;
    elseif n_uRLLC <= 9
        numerology = 3;
    elseif mean_doppler < 100
        numerology = 2;
    else
        numerology = 1;
    end
end
