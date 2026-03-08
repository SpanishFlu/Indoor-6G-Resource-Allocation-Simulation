function per_user = queue_backlog_bits(queues)

U = length(queues);
per_user = zeros(U,1);

for u = 1:U

    embb_bits = 0;
    urllc_bits = 0;

    for k = 1:length(queues{u}.embb)
        embb_bits = embb_bits + queues{u}.embb{k}.remaining;
    end

    for k = 1:length(queues{u}.urllc)
        urllc_bits = urllc_bits + queues{u}.urllc{k}.remaining;
    end

    per_user(u) = embb_bits + urllc_bits;

end

end