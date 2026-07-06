function queues = init_queues(U)
% INIT_QUEUES  Create empty packet queues for each user.
%   queues = init_queues(U)
%   queues is a 1xU struct array. Each element has:
%     .embb  — struct array of eMBB packets (FIFO)
%     .urllc — struct array of URLLC packets (FIFO)
%   Each packet has fields: remaining, arrival_slot, expire_slot.

    empty_pkt = struct('remaining', {}, 'arrival_slot', {}, 'expire_slot', {});
    for u = 1:U
        queues(u).embb  = empty_pkt;
        queues(u).urllc = empty_pkt;
    end
end
