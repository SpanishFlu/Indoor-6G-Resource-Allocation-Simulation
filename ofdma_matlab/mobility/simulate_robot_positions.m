function pos = simulate_robot_positions(cfg)
% SIMULATE_ROBOT_POSITIONS  Lane-based robot motion. Returns pos(T,U,2).
    T=cfg.n_slots; U=cfg.n_robots; dt=cfg.slot_s;
    w=cfg.factory_w_m; h=cfg.factory_h_m;
    x_lanes=lane_centers(w,cfg.lanes_x_n);
    y_lanes=lane_centers(h,cfg.lanes_y_n);
    n_xl=length(x_lanes); n_yl=length(y_lanes);
    pos=zeros(T,U,2);
    speed=cfg.v_min_mps+(cfg.v_max_mps-cfg.v_min_mps)*rand(1,U);
    dir_vals=[-1,1]; direction=dir_vals(randi(2,1,U));
    mode=mod((1:U)-1,2);
    lane_x_id=randi(n_xl,1,U); lane_y_id=randi(n_yl,1,U);
    for u=1:U
        if mode(u)==0; pos(1,u,1)=rand()*w; pos(1,u,2)=y_lanes(lane_y_id(u));
        else; pos(1,u,1)=x_lanes(lane_x_id(u)); pos(1,u,2)=rand()*h; end
    end
    for t=2:T
        pos(t,:,:)=pos(t-1,:,:);
        sw=rand(1,U)<cfg.lane_switch_prob;
        for u=1:U
            if sw(u)
                mode(u)=1-mode(u);
                if mode(u)==0; [~,lane_y_id(u)]=min(abs(y_lanes-pos(t,u,2))); pos(t,u,2)=y_lanes(lane_y_id(u));
                else; [~,lane_x_id(u)]=min(abs(x_lanes-pos(t,u,1))); pos(t,u,1)=x_lanes(lane_x_id(u)); end
            end
            step=direction(u)*speed(u)*dt;
            if mode(u)==0
                pos(t,u,1)=pos(t,u,1)+step;
                if pos(t,u,1)<0; pos(t,u,1)=0; direction(u)=-direction(u); end
                if pos(t,u,1)>w; pos(t,u,1)=w; direction(u)=-direction(u); end
                pos(t,u,2)=y_lanes(lane_y_id(u));
            else
                pos(t,u,2)=pos(t,u,2)+step;
                if pos(t,u,2)<0; pos(t,u,2)=0; direction(u)=-direction(u); end
                if pos(t,u,2)>h; pos(t,u,2)=h; direction(u)=-direction(u); end
                pos(t,u,1)=x_lanes(lane_x_id(u));
            end
        end
    end
end
