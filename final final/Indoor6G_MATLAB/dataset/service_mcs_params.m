function p = service_mcs_params(service)
% SERVICE_MCS_PARAMS  Per-service MCS assumptions for the RB-based
% (Method B) data rate formula. Shared by build_class_user_rate_table.m
% and run_simulation.m so both use identical numbers.
%   p = service_mcs_params(service)   service: 'embb' or 'urllc'
%
%   eMBB:  throughput-first  -> 256-QAM, max code rate, lower overhead
%   URLLC: reliability-first -> conservative 16-QAM, low code rate
%          (more redundancy), higher overhead (control/HARQ assumption)

    switch lower(service)
        case 'embb'
            p.Qm    = 8;          % 256-QAM
            p.Rcode = 948/1024;   % max code rate
            p.OH    = 0.14;       % typical DL overhead
        case 'urllc'
            p.Qm    = 4;          % 16-QAM (robust)
            p.Rcode = 0.50;       % conservative code rate
            p.OH    = 0.18;       % extra control/HARQ overhead assumption
        otherwise
            error('service_mcs_params: unknown service ''%s''', service);
    end
end
