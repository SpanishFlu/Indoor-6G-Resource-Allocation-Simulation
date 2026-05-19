function centers = lane_centers(total_len, n_lanes)
% LANE_CENTERS  Equally spaced lane centers away from walls.
%   centers = lane_centers(total_len, n_lanes)
%   Returns a 1 x n_lanes vector of lane positions.

    idx = 1:n_lanes;
    centers = idx * total_len / (n_lanes + 1);
end
