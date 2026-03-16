function [queues, stats] = enqueuePackets(queues, arrivals, t, CFG, stats)
%ENQUEUEPACKETS Add packet arrivals at slot t into per-user queues
%
% Inputs:
%   queues   : struct array of user queues
%   arrivals : struct with fields embb_bits, urllc_bits [T x U]
%   t        : current slot index (MATLAB: 1-based)
%   CFG      : configuration struct
%   stats    : statistics struct
%
% Outputs:
%   queues   : updated queues
%   stats    : updated stats

    U = numel(queues);

    % Guard against stale trace after changing CFG
    arr_u = size(arrivals.embb_bits, 2);
    if arr_u ~= U
        error(['Trace/CFG mismatch: arrivals have %d users but queues expect %d. ', ...
               'Rebuild trace by running the scenario-trace section again.'], arr_u, U);
    end

    for u = 1:U
        bits_e = arrivals.embb_bits(t, u);
        bits_u = arrivals.urllc_bits(t, u);

        if bits_e > 0
            pkt_e = struct( ...
                'remaining', double(bits_e), ...
                'arrival_slot', t, ...
                'expire_slot', t + CFG.traffic.embb.deadline_slots);

            queues(u).embb{end+1} = pkt_e; %#ok<AGROW>

            stats.arrivals.embb = stats.arrivals.embb + 1;
            stats.arrived_bits.embb = stats.arrived_bits.embb + double(bits_e);
        end

        if bits_u > 0
            pkt_u = struct( ...
                'remaining', double(bits_u), ...
                'arrival_slot', t, ...
                'expire_slot', t + CFG.traffic.urllc.deadline_slots);

            queues(u).urllc{end+1} = pkt_u; %#ok<AGROW>

            stats.arrivals.urllc = stats.arrivals.urllc + 1;
            stats.arrived_bits.urllc = stats.arrived_bits.urllc + double(bits_u);
        end
    end

end