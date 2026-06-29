function [queues,served,stats]=serve_user_packets(queues,u,bit_budget,t,cfg,stats)
% SERVE_USER_PACKETS  Serve URLLC first then eMBB from user u.
    served.embb=0; served.urllc=0;
    classes={'urllc','embb'};
    for ic=1:2
        cls=classes{ic}; dq=queues(u).(cls);
        del_f=['delivered_' cls]; dly_f=['delays_s_' cls];
        while bit_budget>0&&~isempty(dq)
            tx=min(bit_budget,dq(1).remaining);
            dq(1).remaining=dq(1).remaining-tx;
            bit_budget=bit_budget-tx;
            served.(cls)=served.(cls)+tx;
            if dq(1).remaining<=1e-12
                stats.(del_f)=stats.(del_f)+1;
                stats.(dly_f)(end+1)=(t+1-dq(1).arrival_slot)*cfg.slot_s;
                dq(1)=[];
            end
        end
        queues(u).(cls)=dq;
        if bit_budget<=0; break; end
    end
end
