function all_cards = generate_all_cards()
    % 3가지 속성 (모양, 색, 무늬)에 따라 가능한 27장의 카드 생성
    shapes = {'square', 'circle', 'triangle'};
    colors = {'red', 'yellow', 'blue'};
    patterns = {'shade', 'empty', 'filled'};
    
    idx = 1;
    for i = 1:3
        for j = 1:3
            for k = 1:3
                % 각 속성 조합을 하나의 카드로 저장
                all_cards(idx).shape = shapes{i};
                all_cards(idx).color = colors{j};
                all_cards(idx).pattern = patterns{k};
                idx = idx + 1;
            end
        end
    end
end



% 검증 완료