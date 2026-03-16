function robots = initRobots(CFG, x_lanes, y_lanes)
%INITROBOTS Initialize robot states and initial positions

    U = CFG.n_robots;
    w = CFG.factory_w_m;
    h = CFG.factory_h_m;

    robots = struct();

    robots.speed = CFG.v_min_mps + (CFG.v_max_mps - CFG.v_min_mps) * rand(1, U);

    robots.direction = ones(1, U);
    robots.direction(rand(1, U) < 0.5) = -1.0;

    % mode 0: horizontal lane, mode 1: vertical lane
    robots.mode = mod(0:U-1, 2);

    % MATLAB indices start from 1
    robots.lane_x_id = randi(length(x_lanes), 1, U);
    robots.lane_y_id = randi(length(y_lanes), 1, U);

    % current positions [U x 2] -> columns: x, y
    robots.pos = zeros(U, 2);

    % initialize robots on lanes
    for u = 1:U
        if robots.mode(u) == 0
            robots.pos(u, 1) = rand() * w;
            robots.pos(u, 2) = y_lanes(robots.lane_y_id(u));
        else
            robots.pos(u, 1) = x_lanes(robots.lane_x_id(u));
            robots.pos(u, 2) = rand() * h;
        end
    end

end