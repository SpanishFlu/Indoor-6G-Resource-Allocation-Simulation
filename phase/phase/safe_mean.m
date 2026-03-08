function m = safe_mean(x)
if isempty(x)
    m = NaN;
else
    m = mean(x);
end
end
