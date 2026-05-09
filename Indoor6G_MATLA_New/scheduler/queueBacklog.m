function per_user = queueBacklog(queues)
%QUEUEBACKLOG  Total pending bits per user.
    U = length(queues);
    per_user = zeros(U, 1);
    for u = 1:U
        s = 0;
        for k = 1:length(queues{u}.embb),  s = s + queues{u}.embb{k}.remaining;  end
        for k = 1:length(queues{u}.urllc), s = s + queues{u}.urllc{k}.remaining; end
        per_user(u) = s;
    end
end
