function p = los_probability_inh_office(d2d_m)
% LOS_PROBABILITY_INH_OFFICE  3GPP Indoor Office LOS probability.
%   p = los_probability_inh_office(d2d_m)
%   P_LOS = 1                              if d <= 5
%         = exp(-(d-5)/70.8)               if 5 < d <= 49
%         = 0.54*exp(-(d-49)/211.7)        if d > 49

    p = ones(size(d2d_m));
    mid = (d2d_m > 5.0) & (d2d_m <= 49.0);
    far = d2d_m > 49.0;
    p(mid) = exp(-(d2d_m(mid) - 5.0) / 70.8);
    p(far) = 0.54 * exp(-(d2d_m(far) - 49.0) / 211.7);
    p = min(max(p, 0.0), 1.0);
end
