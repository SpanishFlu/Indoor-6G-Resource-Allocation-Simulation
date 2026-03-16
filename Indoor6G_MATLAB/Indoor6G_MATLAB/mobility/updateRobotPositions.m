function [robots, pos_t] = updateRobotPositions(CFG, robots, x_lanes, y_lanes)
%UPDATEROBOTPOSITIONS Update robot positions for one time slot

    U = CFG.n_robots;
    dt = CFG.slot_s;
    w = CFG.factory_w_m;
    h = CFG.factory_h_m;

    switch_lane = rand(1, U) < CFG.lane_switch_prob;

    for u = 1:U
        if switch_lane(u)
            robots.mode(u) = 1 - robots.mode(u);

            if robots.mode(u) == 0
                [~, robots.lane_y_id(u)] = min(abs(y_lanes - robots.pos(u, 2)));
                robots.pos(u, 2) = y_lanes(robots.lane_y_id(u));
            else
                [~, robots.lane_x_id(u)] = min(abs(x_lanes - robots.pos(u, 1)));
                robots.pos(u, 1) = x_lanes(robots.lane_x_id(u));
            end
        end

        step = robots.direction(u) * robots.speed(u) * dt;

        if robots.mode(u) == 0
            % horizontal lane motion
            robots.pos(u, 1) = robots.pos(u, 1) + step;

            if robots.pos(u, 1) < 0.0
                robots.pos(u, 1) = 0.0;
                robots.direction(u) = -robots.direction(u);
            elseif robots.pos(u, 1) > w
                robots.pos(u, 1) = w;
                robots.direction(u) = -robots.direction(u);
            end

            robots.pos(u, 2) = y_lanes(robots.lane_y_id(u));

        else
            % vertical lane motion
            robots.pos(u, 2) = robots.pos(u, 2) + step;

            if robots.pos(u, 2) < 0.0
                robots.pos(u, 2) = 0.0;
                robots.direction(u) = -robots.direction(u);
            elseif robots.pos(u, 2) > h
                robots.pos(u, 2) = h;
                robots.direction(u) = -robots.direction(u);
            end

            robots.pos(u, 1) = x_lanes(robots.lane_x_id(u));
        end
    end

    pos_t = robots.pos;

end