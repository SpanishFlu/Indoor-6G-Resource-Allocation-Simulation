function [slot_features, slot_class_id] = classify_all_slots(cfg, trace)
% CLASSIFY_ALL_SLOTS  Single source-of-truth classification for every real
% simulation slot (t = 1..T).
%   [slot_features, slot_class_id] = classify_all_slots(cfg, trace)
%
%   This runs the deterministic slot-based extraction + classification
%   EXACTLY ONCE per slot, and both the PF scheduler (Method A/B) and the
%   exported waveform_dataset.csv now read from these SAME labels —
%   instead of each independently re-deriving classification with their
%   own random draws (which could disagree on the same slot).

    T = cfg.n_slots;
    slot_features  = zeros(T, 7);
    slot_class_id  = zeros(T, 1);

    for t = 1:T
        feat = extract_slot_features(cfg, trace, t);
        slot_features(t, :) = feat;

        numerology = assign_numerology(feat(5), feat(6), feat(3));
        guard_band = assign_guard_band(feat(2));
        slot_class_id(t) = assign_class(guard_band, numerology);
    end
end
