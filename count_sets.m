function n = count_sets(cards)
    % cards: 구조체 배열 (예: 12장의 카드)
    % 반환값 n: 세트 개수

    n = 0;
    comb = nchoosek(1:length(cards), 3);  % 12C3 조합

    for i = 1:size(comb, 1)
        c1 = cards(comb(i, 1));
        c2 = cards(comb(i, 2));
        c3 = cards(comb(i, 3));

        if is_valid_set(c1, c2, c3)
             fprintf('[SET] (%d, %d, %d): %s-%s-%s / %s-%s-%s / %s-%s-%s\n', ...
        comb(i,1), comb(i,2), comb(i,3), ...
        c1.shape, c1.color, c1.pattern, ...
        c2.shape, c2.color, c2.pattern, ...
        c3.shape, c3.color, c3.pattern);
            
            n = n + 1;
        end
    end
end
