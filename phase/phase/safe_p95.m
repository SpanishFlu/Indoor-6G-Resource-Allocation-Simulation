function p = safe_p95(x)
if isempty(x)
    p = NaN;
else
    p = prctile(x, 95);
end
end