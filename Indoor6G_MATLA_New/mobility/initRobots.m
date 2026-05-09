function robots = initRobots(CFG, x_lanes, y_lanes)
%INITROBOTS  Initialise robot state: position, speed, direction, lane IDs.
    U = CFG.n_robots;
    w = CFG.factory_w_m;
    h = CFG.factory_h_m;

    robots.speed     = CFG.v_min_mps + (CFG.v_max_mps - CFG.v_min_mps) * rand(1, U);
    robots.direction = randsample([-1.0, 1.0], U, true);
    robots.mode      = mod(0:U-1, 2);          % 0 = horizontal, 1 = vertical
    robots.lane_x_id = randi(length(x_lanes), 1, U);
    robots.lane_y_id = randi(length(y_lanes), 1, U);

    robots.pos = zeros(U, 2);
    for u = 1:U
        if robots.mode(u) == 0
            robots.pos(u, 1) = rand * w;
            robots.pos(u, 2) = y_lanes(robots.lane_y_id(u));
        else
            robots.pos(u, 1) = x_lanes(robots.lane_x_id(u));
            robots.pos(u, 2) = rand * h;
        end
    end
end
