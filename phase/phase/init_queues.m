function queues = init_queues(U)

queues = cell(U,1);

for u = 1:U
    queues{u}.embb = {};
    queues{u}.urllc = {};
end

end