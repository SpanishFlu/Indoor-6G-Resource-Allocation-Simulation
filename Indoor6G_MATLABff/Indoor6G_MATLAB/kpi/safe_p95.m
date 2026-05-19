function v = safe_p95(x)
% SAFE_P95  95th percentile; returns NaN for empty input.
    if isempty(x)
        v = NaN;
    else
        v = prctile(x, 95);
    end
end
