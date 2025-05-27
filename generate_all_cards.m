function all_cards = generate_all_cards()
    % 속성 이름과 값 정의
    attr_names = {'shape', 'color', 'pattern', 'number'};
    attr_values = {
        {'square', 'circle', 'triangle'}, ...
        {'red', 'yellow', 'blue'}, ...
        {'shade', 'empty', 'filled'}, ...
        {'one', 'two', 'three'}
    };

    % 가능한 조합 수 계산
    num_attrs = numel(attr_names);
    grid = cell(1, num_attrs);
    [grid{:}] = ndgrid(attr_values{:});  % 속성별 모든 조합 생성
    total = numel(grid{1});  % 전체 카드 수

    % 카드 구조체 초기화
    all_cards = repmat(struct(), total, 1);
    for i = 1:total
        for a = 1:num_attrs
            all_cards(i).(attr_names{a}) = grid{a}(i);
        end
    end

    % cell array 값 → 실제 문자열로 변환 (중첩 제거)
    for i = 1:total
        for a = 1:num_attrs
            val = all_cards(i).(attr_names{a});
            if iscell(val)
                all_cards(i).(attr_names{a}) = val{1};
            end
        end
    end
end
