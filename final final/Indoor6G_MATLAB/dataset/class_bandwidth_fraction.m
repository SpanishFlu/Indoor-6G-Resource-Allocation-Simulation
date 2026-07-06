function frac = class_bandwidth_fraction(numerology, guard_band)
% CLASS_BANDWIDTH_FRACTION  Usable-bandwidth fraction for a
% (numerology, guard_band) combination.
%   frac = class_bandwidth_fraction(numerology, guard_band)
%
%   Shared by build_class_rate_table.m (reference lookup table) and
%   run_simulation.m (PF scheduler's per-slot effective bandwidth), so
%   both use identical numbers. See build_class_rate_table.m for the
%   rationale behind these values.

    scs_util   = [0.90, 0.86, 0.80, 0.72];  % indexed by numerology 1..4
    guard_util = struct('Zero', 1.00, 'Small', 0.95, 'Large', 0.90);

    if isstring(guard_band)
        guard_band = char(guard_band);
    end

    if strcmpi(guard_band, 'Any')
        g = mean(struct2array(guard_util));
    else
        g = guard_util.(guard_band);
    end

    frac = scs_util(numerology) * g;
end
