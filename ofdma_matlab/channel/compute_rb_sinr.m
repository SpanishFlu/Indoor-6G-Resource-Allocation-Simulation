function sinr_lin = compute_rb_sinr(tx_W, pl_dB_bu, noise_W, eps)
% COMPUTE_RB_SINR  SINR for one (BS,robot) link on one RB.
%   sinr_lin = compute_rb_sinr(tx_W, pl_dB_bu, noise_W, eps)
%   pl_dB_bu: scalar path loss [dB]
    sig_W = tx_W * 10^(-pl_dB_bu/10);
    sinr_lin = sig_W / (noise_W + eps);
end
