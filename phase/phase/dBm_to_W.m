function w = dBm_to_W(x_dBm)

w = 10.^((x_dBm - 30.0) ./ 10.0);

end