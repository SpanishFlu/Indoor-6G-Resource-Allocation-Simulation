function class_id = assign_class(guard_band, numerology)
% ASSIGN_CLASS  Map (numerology, guard_band) to class 1..10.
%   Identical lookup table to agenerate_set.m for model compatibility.
%
%   Numerology 4 + Zero/Small/Large → Class 1/2/3
%   Numerology 3 + Zero/Small/Large → Class 4/5/6
%   Numerology 2 + Zero/Small/Large → Class 7/8/9
%   Numerology 1 + any              → Class 10

    class_map = containers.Map( ...
        {'4Zero', '4Small', '4Large', ...
         '3Zero', '3Small', '3Large', ...
         '2Zero', '2Small', '2Large', ...
         '1Zero', '1Small', '1Large'}, ...
        {1, 2, 3, ...
         4, 5, 6, ...
         7, 8, 9, ...
         10, 10, 10});

    key = strcat(num2str(numerology), guard_band);

    if isKey(class_map, key)
        class_id = class_map(key);
    else
        class_id = 10;
    end
end
