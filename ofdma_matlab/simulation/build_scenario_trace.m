function trace = build_scenario_trace(cfg)
% BUILD_SCENARIO_TRACE  Pre-compute mobility, channel, and traffic traces.
    T=cfg.n_slots; B=cfg.n_bs; U=cfg.n_robots;

    % Mobility
    pos = simulate_robot_positions(cfg);   % (T,U,2)

    % Distances (T,B,U)
    d2d=zeros(T,B,U);
    for b=1:B
        dx=pos(:,:,1)-cfg.bs_xy_m(b,1);
        dy=pos(:,:,2)-cfg.bs_xy_m(b,2);
        d2d(:,b,:)=sqrt(dx.^2+dy.^2);
    end
    dh=cfg.bs_height_m-cfg.robot_height_m;
    d3d=sqrt(d2d.^2+dh^2);

    % LOS
    p_los=los_probability_inh_office(d2d);
    los=rand(T,B,U)<p_los;

    % Path loss + shadow fading
    pl=pathloss_inh_office_dB(d3d,cfg.fc_GHz,los);
    sh_sig=cfg.shadow_sigma_nlos_dB*ones(T,B,U);
    sh_sig(los)=cfg.shadow_sigma_los_dB;
    pl=pl+randn(T,B,U).*sh_sig;

    % Per-RB SINR and rate (T,B,U,N_RB) — same channel on all RBs (flat fading)
    % We store per-(t,b,u) SINR; RB allocation handled in simulation loop
    tx_W  =10^((cfg.tx_power_dBm-30)/10);
    noise_W=10^((cfg.noise_dBm-30)/10);
    rx_W  =tx_W.*10.^(-pl/10);       % (T,B,U)
    snr_lin=rx_W/noise_W;

    % Interference-free spectral efficiency per RB [bps/Hz]
    se_no_int=log2(1+snr_lin);        % (T,B,U)

    % Interference-free rate per RB [bps]
    rate_rb_no_int=cfg.rb_bw_hz.*se_no_int;

    % Traffic
    arrivals=build_arrival_trace(cfg);

    % Pack
    trace.pos            =pos;
    trace.d2d            =d2d;
    trace.d3d            =d3d;
    trace.los            =los;
    trace.pl_dB          =pl;
    trace.snr_lin        =snr_lin;
    trace.se_no_int      =se_no_int;
    trace.rate_rb_no_int =rate_rb_no_int;   % (T,B,U)
    trace.noise_dBm      =cfg.noise_dBm;
    trace.arrivals       =arrivals;
    trace.tx_W           =tx_W;
    trace.noise_W        =noise_W;
end
