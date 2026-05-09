function d2d = computeDistance(pos, bs_xy)
%COMPUTEDISTANCE  2D distance [T, B, U] between robots and base stations.
    [T, U, ~] = size(pos);
    B = size(bs_xy, 1);
    d2d = zeros(T, B, U);
    for t = 1:T
        for b = 1:B
            for u = 1:U
                dx = pos(t, u, 1) - bs_xy(b, 1);
                dy = pos(t, u, 2) - bs_xy(b, 2);
                d2d(t, b, u) = sqrt(dx^2 + dy^2);
            end
        end
    end
end
