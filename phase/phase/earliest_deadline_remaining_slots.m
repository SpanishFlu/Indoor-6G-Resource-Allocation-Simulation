function rem = earliest_deadline_remaining_slots(queues, now_slot)

U = length(queues);
rem = inf(1, U);

for u = 1:U
    
    classes = ["urllc","embb"];
    
    for c = 1:length(classes)
        
        cls = classes(c);
        q = queues(u).(cls);
        
        if ~isempty(q)
            expire_slot = q(1).expire_slot;
            rem(u) = min(rem(u), expire_slot - now_slot);
        end
        
    end
    
end

end