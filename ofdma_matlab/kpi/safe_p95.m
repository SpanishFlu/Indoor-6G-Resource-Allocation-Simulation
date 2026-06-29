function v=safe_p95(x); if isempty(x); v=NaN; else; v=prctile(x,95); end; end
