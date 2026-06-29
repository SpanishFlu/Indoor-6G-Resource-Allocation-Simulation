function per_user=queue_backlog_bits(queues)
% QUEUE_BACKLOG_BITS  Remaining bits per user.
    U=length(queues); per_user=zeros(1,U);
    for u=1:U
        s=0;
        for k=1:length(queues(u).embb);  s=s+queues(u).embb(k).remaining;  end
        for k=1:length(queues(u).urllc); s=s+queues(u).urllc(k).remaining; end
        per_user(u)=s;
    end
end
