function queues = initQueues(U)
%INITQUEUES  Create empty eMBB and URLLC queues for each robot.
    queues = cell(U, 1);
    for u = 1:U
        queues{u}.embb  = {};
        queues{u}.urllc = {};
    end
end
