function guard_band = assign_guard_band(var_delay)
% ASSIGN_GUARD_BAND  Select guard band based on delay spread variance.
%
%   Thresholds calibrated to the physical delay variance distribution
%   from 3GPP TR 38.901 Indoor Factory log-normal delay spread model.
%
%   Physical range: ~0.01 to ~7.5 µs², with bulk of samples below 0.5.
%   Thresholds chosen to produce a meaningful three-way split:
%
%     var_delay > 0.30  → "Zero"  (wide delay spread, stable average)
%     var_delay > 0.10  → "Small" (moderate variation)
%     var_delay ≤ 0.10  → "Large" (tight cluster, potential INI sensitivity)
%
%   Higher variance indicates users experience diverse delay conditions.
%   Lower variance means homogeneous delay → more sensitive to INI →
%   larger guard band needed.

    if var_delay > 0.30
        guard_band = "Zero";
    elseif var_delay > 0.10
        guard_band = "Small";
    else
        guard_band = "Large";
    end
end
