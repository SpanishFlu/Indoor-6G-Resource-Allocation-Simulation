function n = thermal_noise_dBm(bandwidth_Hz, noise_figure_dB)

n = -174.0 + 10.0 .* log10(bandwidth_Hz) + noise_figure_dB;

end