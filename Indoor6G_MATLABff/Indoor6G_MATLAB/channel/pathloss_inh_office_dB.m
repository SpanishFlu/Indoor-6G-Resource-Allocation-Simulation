function pl = pathloss_inh_office_dB(d3d_m, fc_GHz, los_mask)
% PATHLOSS_INH_OFFICE_DB  3GPP Indoor Office pathloss.
%   pl = pathloss_inh_office_dB(d3d_m, fc_GHz, los_mask)
%   PL_LOS  = 32.4 + 17.3*log10(d3D) + 20*log10(fc)
%   PL_NLOS = 17.3 + 38.3*log10(d3D) + 24.9*log10(fc)
%   PL = PL_LOS if LOS, else max(PL_LOS, PL_NLOS)

    d = max(d3d_m, 1.0);
    pl_los  = 32.4 + 17.3 * log10(d) + 20.0 * log10(fc_GHz);
    pl_nlos = 17.3 + 38.3 * log10(d) + 24.9 * log10(fc_GHz);

    pl = zeros(size(d));
    pl(los_mask)  = pl_los(los_mask);
    pl(~los_mask) = max(pl_los(~los_mask), pl_nlos(~los_mask));
end
