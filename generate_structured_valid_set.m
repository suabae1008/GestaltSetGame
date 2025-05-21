function set_cards = generate_structured_valid_set()
    
    % 세트 조건을 직접 구성해서 유효한 세트 1개를 생성
    shapes = {'square', 'circle', 'triangle'};
    colors = {'red', 'yellow', 'blue'};
    patterns = {'shade', 'empty', 'filled'};
    
    % 속성 리스트
    attrs = {shapes, colors, patterns};
    set_cards = struct('shape', '', 'color', '', 'pattern', '');

    % 속성별로 '같음'(1) or '다름'(0)을 랜덤 선택
    same_flags = randi([0, 1], 1, 3);

    for attr_idx = 1:3
        options = attrs{attr_idx};
        if same_flags(attr_idx) == 1
            % 3개 속성이 모두 같도록
            val = options{randi(3)};
            for k = 1:3
                set_cards(k).(get_attr_name(attr_idx)) = val;
            end
        else
            % 3개 속성이 모두 다르도록 (shuffle)
            shuffled = options(randperm(3));
            for k = 1:3
                set_cards(k).(get_attr_name(attr_idx)) = shuffled{k};
            end
        end
    end
end

function name = get_attr_name(i)
    % 속성 인덱스를 이름으로 변환
    switch i
        case 1
            name = 'shape';
        case 2
            name = 'color';
        case 3
            name = 'pattern';
    end
end
