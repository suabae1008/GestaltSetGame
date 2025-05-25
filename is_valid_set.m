function valid = is_valid_set(card1, card2, card3)
    % 세 장의 카드가 세트 조건을 만족하는지 검사
    % 각 속성에 대해 "전부 같거나 전부 다르면" 세트로 인정
    valid = true;
    fields = {'shape', 'color', 'pattern'};
    
    for i = 1:length(fields)
        % 해당 속성의 값만 추출
        vals = {card1.(fields{i}), card2.(fields{i}), card3.(fields{i})};
        num_unique = length(unique(vals)); % 서로 다른 값 개수
        
        % 2개만 같고 1개 다른 경우 → 세트 성립 안 됨
        if num_unique == 2
            valid = false;
            return;
        end
    end
end


% 검증 완료 