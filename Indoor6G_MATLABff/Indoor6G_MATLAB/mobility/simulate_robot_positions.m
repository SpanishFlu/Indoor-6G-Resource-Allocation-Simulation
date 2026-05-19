function pos = simulate_robot_positions(cfg)
% SIMULATE_ROBOT_POSITIONS  Lane-based robot motion inside factory.
%   pos = simulate_robot_positions(cfg)
%   Returns pos(T, U, 2) — robot xy positions for every slot.

    T  = cfg.n_slots;
    U  = cfg.n_robots;
    dt = cfg.slot_s;
    w  = cfg.factory_w_m;
    h  = cfg.factory_h_m;

    x_lanes = lane_centers(w, cfg.lanes_x_n);
    y_lanes = lane_centers(h, cfg.lanes_y_n);
    n_xl = length(x_lanes);
    n_yl = length(y_lanes);

    pos = zeros(T, U, 2);

    % random speed per robot
    speed     = cfg.v_min_mps + (cfg.v_max_mps - cfg.v_min_mps) * rand(1, U);
    % random direction (+1 or -1)
    dir_vals  = [-1.0, 1.0];
    direction = dir_vals(randi(2, 1, U));

    % mode: 0 = horizontal lane, 1 = vertical lane
    mode = mod((1:U) - 1, 2);  % alternating: 0,1,0,...

    % random lane IDs (1-based)
    lane_x_id = randi(n_xl, 1, U);
    lane_y_id = randi(n_yl, 1, U);

    % initialize positions on lanes
    for u = 1:U
        if mode(u) == 0
            pos(1, u, 1) = rand() * w;
            pos(1, u, 2) = y_lanes(lane_y_id(u));
        else
            pos(1, u, 1) = x_lanes(lane_x_id(u));
            pos(1, u, 2) = rand() * h;
        end
    end

    for t = 2:T
        pos(t, :, :) = pos(t-1, :, :);

        % per-robot lane switch decision
        switch_lane = rand(1, U) < cfg.lane_switch_prob;

        for u = 1:U
            if switch_lane(u)
                mode(u) = 1 - mode(u);
                if mode(u) == 0
                    % snap to nearest horizontal lane
                    [~, lane_y_id(u)] = min(abs(y_lanes - pos(t, u, 2)));
                    pos(t, u, 2) = y_lanes(lane_y_id(u));
                else
                    % snap to nearest vertical lane
                    [~, lane_x_id(u)] = min(abs(x_lanes - pos(t, u, 1)));
                    pos(t, u, 1) = x_lanes(lane_x_id(u));
                end
            end

            step = direction(u) * speed(u) * dt;

            if mode(u) == 0
                % horizontal lane motion
                pos(t, u, 1) = pos(t, u, 1) + step;
                if pos(t, u, 1) < 0.0
                    pos(t, u, 1) = 0.0;
                    direction(u) = -direction(u);
                elseif pos(t, u, 1) > w
                    pos(t, u, 1) = w;
                    direction(u) = -direction(u);
                end
                pos(t, u, 2) = y_lanes(lane_y_id(u));
            else
                % vertical lane motion
                pos(t, u, 2) = pos(t, u, 2) + step;
                if pos(t, u, 2) < 0.0
                    pos(t, u, 2) = 0.0;
                    direction(u) = -direction(u);
                elseif pos(t, u, 2) > h
                    pos(t, u, 2) = h;
                    direction(u) = -direction(u);
                end
                pos(t, u, 1) = x_lanes(lane_x_id(u));
            end
        end
    end
end
