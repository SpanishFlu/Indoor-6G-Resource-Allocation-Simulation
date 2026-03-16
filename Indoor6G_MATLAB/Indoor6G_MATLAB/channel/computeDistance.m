function d = computeDistance(pos_t_u_xy, bs_xy)
%COMPUTEDISTANCE Compute distances with shape [T, B, U]
%
% Inputs:
%   pos_t_u_xy : [T x U x 2]
%   bs_xy      : [B x 2]
%
% Output:
%   d          : [T x B x U]

    T = size(pos_t_u_xy, 1);
    U = size(pos_t_u_xy, 2);
    B = size(bs_xy, 1);

    d = zeros(T, B, U);

    for t = 1:T
        for b = 1:B
            dx = squeeze(pos_t_u_xy(t, :, 1))' - bs_xy(b, 1);
            dy = squeeze(pos_t_u_xy(t, :, 2))' - bs_xy(b, 2);
            d(t, b, :) = sqrt(dx.^2 + dy.^2);
        end
    end

end