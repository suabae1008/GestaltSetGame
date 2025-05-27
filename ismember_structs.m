function mask = ismember_structs(big, small)
    if isempty(big) || isempty(small)
        mask = false(1, length(big));
        return;
    end

    % 구조체의 공통 필드 추출
    attr_names = fieldnames(big);

    mask = false(1, length(big));
    for i = 1:length(big)
        for j = 1:length(small)
            is_match = true;
            for a = 1:numel(attr_names)
                field = attr_names{a};
                if ~isequal(big(i).(field), small(j).(field))
                    is_match = false;
                    break;
                end
            end
            if is_match
                mask(i) = true;
                break;
            end
        end
    end
end
