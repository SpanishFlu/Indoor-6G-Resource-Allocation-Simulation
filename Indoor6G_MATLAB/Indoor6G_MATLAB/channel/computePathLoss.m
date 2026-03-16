function pl_dB = computePathLoss(d3d_m, fc_GHz, los_mask)
%COMPUTEPATHLOSS Indoor Hotspot office path loss in dB
%
% Inputs:
%   d3d_m    : 3D distance(s) in meters
%   fc_GHz   : carrier frequency in GHz
%   los_mask : logical LOS mask, same size as d3d_m
%
% Output:
%   pl_dB    : path loss in dB

    d = max(d3d_m, 1.0);

    pl_los  = 32.4 + 17.3 .* log10(d) + 20.0 .* log10(fc_GHz);
    pl_nlos = 17.3 + 38.3 .* log10(d) + 24.9 .* log10(fc_GHz);

    pl_dB = pl_nlos;
    pl_dB(los_mask) = pl_los(los_mask);

    nlos_idx = ~los_mask;
    pl_dB(nlos_idx) = max(pl_los(nlos_idx), pl_nlos(nlos_idx));

end