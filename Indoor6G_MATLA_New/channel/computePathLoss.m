function PL = computePathLoss(d3d_m, fc_GHz, los_mask)
%COMPUTEPATHLOSS  InH-Office path loss (3GPP TR 38.901).
    d = max(d3d_m, 1.0);
    pl_los  = 32.4 + 17.3 .* log10(d) + 20.0 .* log10(fc_GHz);
    pl_nlos = 17.3 + 38.3 .* log10(d) + 24.9 .* log10(fc_GHz);
    PL = pl_los;
    idx = ~los_mask;
    PL(idx) = max(pl_los(idx), pl_nlos(idx));
end
