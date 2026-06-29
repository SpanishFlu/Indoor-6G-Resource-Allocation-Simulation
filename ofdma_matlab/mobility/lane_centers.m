function centers = lane_centers(total_len, n_lanes)
% LANE_CENTERS  Equally spaced lane centers.
    centers = (1:n_lanes) * total_len / (n_lanes + 1);
end
