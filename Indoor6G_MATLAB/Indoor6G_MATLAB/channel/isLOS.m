function p = isLOS(d2d_m)
%ISLOS LOS probability for Indoor Hotspot office scenario
%
% Input:
%   d2d_m : 2D distance(s) in meters
%
% Output:
%   p     : LOS probability, same size as d2d_m

    d = d2d_m;
    p = zeros(size(d));

    p(d <= 5.0) = 1.0;

    mid = (d > 5.0) & (d <= 49.0);
    far = d > 49.0;

    p(mid) = exp(-(d(mid) - 5.0) / 70.8);
    p(far) = 0.54 .* exp(-(d(far) - 49.0) / 211.7);

    p = min(max(p, 0.0), 1.0);

end