function [rx_dBm, noise_dBm, snr_dB, rate_no_int_bps] = computeSINR(CFG, pl_dB)
%COMPUTESINR Compute received power, noise, SNR, and no-interference rate
%
% Inputs:
%   CFG   : configuration struct
%   pl_dB : path loss tensor [T x B x U]
%
% Outputs:
%   rx_dBm         : received power [dBm]
%   noise_dBm      : scalar noise power [dBm]
%   snr_dB         : SNR tensor [dB]
%   rate_no_int_bps: Shannon rate tensor [bps]

    noise_dBm = -174.0 + 10.0 * log10(CFG.bandwidth_Hz) + CFG.noise_figure_dB;

    rx_dBm = CFG.tx_power_dBm - pl_dB;
    snr_dB = rx_dBm - noise_dBm;

    rate_no_int_bps = CFG.bandwidth_Hz .* log2(1.0 + 10.^(snr_dB ./ 10.0));

end