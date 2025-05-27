function mask = ismember_structs(big, small)
    mask = false(1, length(big));
    for i = 1:length(big)
        for j = 1:length(small)
            if isequal(big(i).shape, small(j).shape) && ...
               isequal(big(i).color, small(j).color) && ...
               isequal(big(i).pattern, small(j).pattern)
                mask(i) = true;
                break;
            end
        end
    end
end
