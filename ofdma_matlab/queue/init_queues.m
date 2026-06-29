function queues = init_queues(U)
% INIT_QUEUES  Empty packet queues for U users.
    empty_pkt=struct('remaining',{},'arrival_slot',{},'expire_slot',{});
    for u=1:U; queues(u).embb=empty_pkt; queues(u).urllc=empty_pkt; end
end
