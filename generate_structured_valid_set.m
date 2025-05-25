function set_cards = generate_structured_valid_set()
    shapes = {'square', 'circle', 'triangle'};
    colors = {'red', 'yellow', 'blue'};
    patterns = {'shade', 'empty', 'filled'};
    attrs = {shapes, colors, patterns};

    all_cards = generate_all_cards();  % 전체 카드 풀
    raw_set = struct('shape', {}, 'color', {}, 'pattern', {});

    while true
        same_flags = randi([0, 1], 1, 3);
        if sum(same_flags) == 3
            continue;  % 완전 동일한 3장은 패스
        end

        % 속성 조합대로 3장 생성
        for attr_idx = 1:3
            options = attrs{attr_idx};
            field = get_attr_name(attr_idx);
            if same_flags(attr_idx) == 1
                val = options{randi(3)};
                for k = 1:3
                    raw_set(k).(field) = val;
                end
            else
                vals = options(randperm(3));
                for k = 1:3
                    raw_set(k).(field) = vals{k};
                end
            end
        end

        % 반드시 all_cards 안에서 매칭된 인스턴스로 대체
        set_cards = struct('shape', {}, 'color', {}, 'pattern', {});

        for k = 1:3
            mask = ismember_structs(all_cards, raw_set(k));
            idx = find(mask, 1);
            if isempty(idx)
                error('카드 %d가 all_cards에 없음', k);
            end
            set_cards(k) = all_cards(idx);
        end

        return;
    end
end

function name = get_attr_name(i)
    switch i
        case 1, name = 'shape';
        case 2, name = 'color';
        case 3, name = 'pattern';
    end
end
