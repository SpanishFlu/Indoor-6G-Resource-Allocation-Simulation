function [x_lanes, y_lanes] = generateLanes(CFG)
%GENERATELANES  Compute equally-spaced lane center positions.
    x_lanes = (1:CFG.lanes_x_n) * CFG.factory_w_m / (CFG.lanes_x_n + 1);
    y_lanes = (1:CFG.lanes_y_n) * CFG.factory_h_m / (CFG.lanes_y_n + 1);
end
