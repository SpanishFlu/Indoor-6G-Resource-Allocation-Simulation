function [x_lanes, y_lanes] = generateLanes(CFG)
%GENERATELANES Generate equally spaced lane centers away from walls

    x_idx = 1:CFG.lanes_x_n;
    y_idx = 1:CFG.lanes_y_n;

    x_lanes = x_idx * CFG.factory_w_m / (CFG.lanes_x_n + 1);
    y_lanes = y_idx * CFG.factory_h_m / (CFG.lanes_y_n + 1);

end