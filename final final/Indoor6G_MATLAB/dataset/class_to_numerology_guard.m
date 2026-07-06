function [numerology, guard_band] = class_to_numerology_guard(class_id)
% CLASS_TO_NUMEROLOGY_GUARD  Inverse of assign_class.m: class (1..10) ->
% (numerology, guard_band). Used by run_simulation.m to recover the
% bandwidth-relevant parameters from a precomputed class label without
% re-deriving classification.

    class_defs = { ...
        1, 4, 'Zero';  2, 4, 'Small';  3, 4, 'Large'; ...
        4, 3, 'Zero';  5, 3, 'Small';  6, 3, 'Large'; ...
        7, 2, 'Zero';  8, 2, 'Small';  9, 2, 'Large'; ...
        10, 1, 'Any' };

    row = find(cellfun(@(c) c == class_id, class_defs(:,1)));
    if isempty(row)
        error('class_to_numerology_guard: unknown class_id %d', class_id);
    end
    numerology = class_defs{row, 2};
    guard_band = class_defs{row, 3};
end
