function queues = initQueues(U)
%INITQUEUES Initialize per-user packet queues
%
% Output:
%   queues(u).embb  -> cell array of packet structs
%   queues(u).urllc -> cell array of packet structs

    emptyQueue = struct('embb', {{}}, 'urllc', {{}});
    queues = repmat(emptyQueue, 1, U);

end