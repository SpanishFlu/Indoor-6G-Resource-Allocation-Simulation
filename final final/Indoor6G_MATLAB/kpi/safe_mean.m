function v = safe_mean(x)
% SAFE_MEAN  Mean that returns NaN for empty input.
    if isempty(x)
        v = NaN;
    else
        v = mean(x);
    end
end
