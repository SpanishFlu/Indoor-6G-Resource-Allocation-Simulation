function stats = run_simulation(cfg, trace, scheduler_name)
% RUN_SIMULATION  OFDMA simulation for one scheduler.
%   Each slot: allocate N_RB resource blocks → serve packets.

    T=cfg.n_slots; B=cfg.n_bs; U=cfg.n_robots; N_RB=cfg.n_rb;

    queues=init_queues(U);
    avg_user_rate=1e3*ones(1,U);

    % Stats
    stats.scheduler       =scheduler_name;
    stats.arrivals_embb   =0; stats.arrivals_urllc  =0;
    stats.arrived_bits_embb=0;stats.arrived_bits_urllc=0;
    stats.delivered_embb  =0; stats.delivered_urllc =0;
    stats.drops_embb      =0; stats.drops_urllc     =0;
    stats.delays_s_embb   =[]; stats.delays_s_urllc =[];
    stats.served_bits_embb=0; stats.served_bits_urllc=0;
    stats.served_user_bits=zeros(1,U);
    stats.backlog_bits    =zeros(T,1);
    stats.rb_utilization  =zeros(T,1);

    for t=1:T
        % Arrivals & drops
        [queues,stats]=add_arrivals_to_queues(queues,trace.arrivals,t,cfg,stats);
        [queues,stats]=drop_expired_packets(queues,t,stats);

        backlog=queue_backlog_bits(queues);
        has_backlog=backlog>0;

        % Per-robot best-BS SINR (interference-free) for scheduling metric
        % rate_rb_no_int(t,b,u) — take max over BSs
        rate_t=squeeze(trace.rate_rb_no_int(t,:,:));   % B x U
        if B==1; rate_t=rate_t(:)'; end
        best_rate=max(rate_t,[],1);                     % 1 x U

        deadline_left=earliest_deadline_remaining_slots(queues,t);

        % RB allocation
        rb_alloc=allocate_rbs(scheduler_name,has_backlog, ...
                              rate_t,avg_user_rate,deadline_left,N_RB,cfg.eps);

        % Count RBs per user
        rb_count=zeros(1,U);
        for rb=1:N_RB
            u=rb_alloc(rb);
            if u>0; rb_count(u)=rb_count(u)+1; end
        end

        used_rbs=sum(rb_count);
        stats.rb_utilization(t)=used_rbs/N_RB;

        inst_user_rate=zeros(1,U);

        % Serve each user with their allocated RBs
        for u=1:U
            if rb_count(u)==0; continue; end

            % Find best BS for this user
            [~,best_b]=max(rate_t(:,u));
            pl_bu=trace.pl_dB(t,best_b,u);

            % Compute SINR with interference
            sig_W=trace.tx_W*10^(-pl_bu/10);
            interf_W=0;
            for b2=1:B
                if b2==best_b; continue; end
                % Check if another user is served by b2
                % (simple: any user served = possible interferer)
                if any(rb_alloc>0)
                    interf_W=interf_W+trace.tx_W*10^(-trace.pl_dB(t,b2,u)/10);
                end
            end
            sinr=sig_W/(trace.noise_W+interf_W+cfg.eps);
            se_rb=log2(1+sinr);                         % bits/s/Hz per RB
            rate_per_rb=cfg.rb_bw_hz*se_rb;             % bps per RB
            bit_budget=rb_count(u)*rate_per_rb*cfg.slot_s;

            [queues,served,stats]=serve_user_packets(queues,u,bit_budget,t,cfg,stats);
            su=served.embb+served.urllc;
            stats.served_bits_embb =stats.served_bits_embb +served.embb;
            stats.served_bits_urllc=stats.served_bits_urllc+served.urllc;
            stats.served_user_bits(u)=stats.served_user_bits(u)+su;
            inst_user_rate(u)=inst_user_rate(u)+su/cfg.slot_s;
        end

        avg_user_rate=cfg.pf_alpha*avg_user_rate+(1-cfg.pf_alpha)*inst_user_rate;
        stats.backlog_bits(t)=sum(queue_backlog_bits(queues));
    end
end
