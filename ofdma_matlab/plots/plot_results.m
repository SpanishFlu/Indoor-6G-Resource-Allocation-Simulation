function plot_results(cfg,trace,rr_s,pf_s,dl_s,sum_rr,sum_pf,sum_dl)
% PLOT_RESULTS  All simulation figures.
    t_vec=(0:cfg.n_slots-1)*cfg.slot_s;

    % A: Factory layout
    figure('Name','Factory Layout');
    hold on;
    plot([0,cfg.factory_w_m,cfg.factory_w_m,0,0],[0,0,cfg.factory_h_m,cfg.factory_h_m,0],'k-','LineWidth',1.5);
    scatter(cfg.bs_xy_m(:,1),cfg.bs_xy_m(:,2),120,'r','^','filled','DisplayName','BS');
    clr=lines(cfg.n_robots);
    for u=1:cfg.n_robots
        xy=squeeze(trace.pos(:,u,:));
        plot(xy(:,1),xy(:,2),'LineWidth',1.5,'Color',clr(u,:),'DisplayName',sprintf('Robot %d',u));
    end
    title('Factory layout and robot trajectories');
    xlabel('x [m]'); ylabel('y [m]'); axis equal; grid on; legend; hold off;

    % B: Distance evolution
    figure('Name','Distance Evolution'); hold on;
    for u=1:cfg.n_robots
        plot(t_vec,squeeze(trace.d2d(:,1,u)),'DisplayName',sprintf('BS1-Robot%d',u));
    end
    title('Distance evolution (BS1 to robots)');
    xlabel('time [s]'); ylabel('distance [m]'); grid on; legend; hold off;

    % C: Backlog
    figure('Name','Queue Backlog'); hold on;
    plot(t_vec,rr_s.backlog_bits/1e6,'DisplayName','RR');
    plot(t_vec,pf_s.backlog_bits/1e6,'DisplayName','PF');
    plot(t_vec,dl_s.backlog_bits/1e6,'DisplayName','Deadline');
    title('Total queue backlog over time');
    xlabel('time [s]'); ylabel('backlog [Mbits]'); grid on; legend; hold off;

    % D: KPI bars
    names={'RR','PF','Deadline'};
    x=1:3; w=0.35;
    figure('Name','KPI Dashboard','Position',[100,100,1400,350]);

    subplot(1,5,1);
    bar(categorical(names),[sum_rr.served_Mbps,sum_pf.served_Mbps,sum_dl.served_Mbps]);
    title('Served Throughput'); ylabel('Mbps'); grid on;

    subplot(1,5,2);
    hold on;
    bar(x-w/2,[sum_rr.embb_success,sum_pf.embb_success,sum_dl.embb_success],w,'DisplayName','eMBB');
    bar(x+w/2,[sum_rr.urllc_success,sum_pf.urllc_success,sum_dl.urllc_success],w,'DisplayName','URLLC');
    set(gca,'XTick',x,'XTickLabel',names); ylim([0,1.05]);
    title('Packet Success Rate'); legend; grid on; hold off;

    subplot(1,5,3);
    hold on;
    bar(x-w/2,[sum_rr.embb_delay_mean_ms,sum_pf.embb_delay_mean_ms,sum_dl.embb_delay_mean_ms],w,'DisplayName','eMBB');
    bar(x+w/2,[sum_rr.urllc_delay_mean_ms,sum_pf.urllc_delay_mean_ms,sum_dl.urllc_delay_mean_ms],w,'DisplayName','URLLC');
    set(gca,'XTick',x,'XTickLabel',names);
    title('Mean Packet Delay'); ylabel('ms'); legend; grid on; hold off;

    subplot(1,5,4);
    bar(categorical(names),[sum_rr.jain_fairness,sum_pf.jain_fairness,sum_dl.jain_fairness]);
    title('Jain Fairness Index'); ylim([0,1.05]); grid on;

    subplot(1,5,5);
    bar(categorical(names),[sum_rr.rb_utilization,sum_pf.rb_utilization,sum_dl.rb_utilization]);
    title('RB Utilization'); ylim([0,1.05]); grid on;

    % E: RB utilization over time
    figure('Name','RB Utilization Over Time'); hold on;
    plot(t_vec,rr_s.rb_utilization,'DisplayName','RR');
    plot(t_vec,pf_s.rb_utilization,'DisplayName','PF');
    plot(t_vec,dl_s.rb_utilization,'DisplayName','Deadline');
    title('Resource Block Utilization Over Time');
    xlabel('time [s]'); ylabel('Utilization'); ylim([0,1.1]); grid on; legend; hold off;
end
