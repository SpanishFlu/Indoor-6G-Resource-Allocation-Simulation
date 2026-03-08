function centers = lane_centers(total_len, n_lanes)
% Equally spaced lane centers away from walls

idx = 1:n_lanes;
centers = idx * total_len / (n_lanes + 1);

end