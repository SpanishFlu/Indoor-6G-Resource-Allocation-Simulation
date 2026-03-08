function p = los_probability_inh_office(d2d_m)
% P_LOS = 1 (d<=5)
% P_LOS = exp(-(d-5)/70.8) (5<d<=49)
% P_LOS = 0.54*exp(-(d-49)/211.7) (d>49)

d = d2d_m;
p = zeros(size(d));

p(d <= 5.0) = 1.0;

mid = (d > 5.0) & (d <= 49.0);
far = (d > 49.0);

p(mid) = exp(-(d(mid) - 5.0) ./ 70.8);
p(far) = 0.54 .* exp(-(d(far) - 49.0) ./ 211.7);

p = max(min(p,1.0),0.0);

end