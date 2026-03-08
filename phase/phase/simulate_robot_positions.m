function pos = simulate_robot_positions(cfg)

T = cfg.n_slots;
U = cfg.n_robots;
dt = cfg.slot_s;

w = cfg.factory_w_m;
h = cfg.factory_h_m;

x_lanes = lane_centers(w, cfg.lanes_x_n);
y_lanes = lane_centers(h, cfg.lanes_y_n);

pos = zeros(T, U, 2);

speed = cfg.v_min_mps + (cfg.v_max_mps - cfg.v_min_mps) * rand(1,U);
direction = randsample([-1 1],U,true);

% mode 0 = horizontal, mode 1 = vertical
mode = mod(0:U-1,2);

lane_x_id = randi(length(x_lanes),1,U);
lane_y_id = randi(length(y_lanes),1,U);

% initialize robots
for u = 1:U
    if mode(u) == 0
        pos(1,u,1) = rand*w;
        pos(1,u,2) = y_lanes(lane_y_id(u));
    else
        pos(1,u,1) = x_lanes(lane_x_id(u));
        pos(1,u,2) = rand*h;
    end
end

for t = 2:T

    pos(t,:,:) = pos(t-1,:,:);

    switch_lane = rand(1,U) < cfg.lane_switch_prob;

    for u = 1:U

        if switch_lane(u)

            mode(u) = 1 - mode(u);

            if mode(u) == 0
                [~,lane_y_id(u)] = min(abs(y_lanes - pos(t,u,2)));
                pos(t,u,2) = y_lanes(lane_y_id(u));
            else
                [~,lane_x_id(u)] = min(abs(x_lanes - pos(t,u,1)));
                pos(t,u,1) = x_lanes(lane_x_id(u));
            end

        end

        step = direction(u)*speed(u)*dt;

        if mode(u) == 0

            % horizontal motion
            pos(t,u,1) = pos(t,u,1) + step;

            if pos(t,u,1) < 0
                pos(t,u,1) = 0;
                direction(u) = -direction(u);

            elseif pos(t,u,1) > w
                pos(t,u,1) = w;
                direction(u) = -direction(u);
            end

            pos(t,u,2) = y_lanes(lane_y_id(u));

        else

            % vertical motion
            pos(t,u,2) = pos(t,u,2) + step;

            if pos(t,u,2) < 0
                pos(t,u,2) = 0;
                direction(u) = -direction(u);

            elseif pos(t,u,2) > h
                pos(t,u,2) = h;
                direction(u) = -direction(u);
            end

            pos(t,u,1) = x_lanes(lane_x_id(u));

        end

    end
end

end