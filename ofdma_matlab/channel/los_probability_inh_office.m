function p = los_probability_inh_office(d2d_m)
% LOS_PROBABILITY_INH_OFFICE  3GPP TR 38.901 InH-Office LOS probability.
    p=ones(size(d2d_m));
    mid=(d2d_m>5)&(d2d_m<=49); far=d2d_m>49;
    p(mid)=exp(-(d2d_m(mid)-5)/70.8);
    p(far)=0.54*exp(-(d2d_m(far)-49)/211.7);
    p=min(max(p,0),1);
end
