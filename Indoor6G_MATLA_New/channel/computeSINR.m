function [rx_dBm, noise_dBm, snr_dB, rate_bps] = computeSINR(CFG, pl_dB)
%COMPUTESINR  Received power, thermal noise, SNR, and interference-free rate.
    noise_dBm = -174.0 + 10.0 * log10(CFG.bandwidth_Hz) + CFG.noise_figure_dB;
    rx_dBm    = CFG.tx_power_dBm - pl_dB;
    snr_dB    = rx_dBm - noise_dBm;
    rate_bps  = CFG.bandwidth_Hz .* log2(1.0 + 10.^(snr_dB ./ 10.0));
end
