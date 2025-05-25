% function score = compute_danger_score(candidate, board)
%     % 후보 카드와 현재 보드에 있는 카드들 간의 세트 위험도 점수 계산
%     % 위험도 = 실제 세트를 만드는 조합 (100점), 거의 세트 될 뻔한 조합 (1점)
% 
%     score = 0;
% 
%     for i = 1:length(board)
%         for j = i+1:length(board)
%             match = 0;
%             fields = {'shape', 'color', 'pattern'};
% 
%             for k = 1:3
%                 vals = {board(i).(fields{k}), board(j).(fields{k}), candidate.(fields{k})};
%                 num_unique = length(unique(vals));
% 
%                 % 세트 조건: 모두 같거나 모두 다름 (num_unique == 1 or 3)
%                 if num_unique == 1 || num_unique == 3
%                     match = match + 1;
%                 end
%             end
% 
%             if match == 3
%                 score = score + 100;  % 완전한 세트 → 강한 패널티
%             elseif match == 2
%                 score = score + 1;    % 거의 세트 → 약한 위험
%             end
%         end
%     end
% end


function score = compute_danger_score(candidate, board)
    % danger score = 후보 카드가 보드 카드 2장과 세트를 만들 경우,
    % 속성별 다양성과 세트 성립 방식(same/diff)에 따라 위험도 가중

    fields = {'shape', 'color', 'pattern'};
    score = 0;

    % 🟡 1. 보드 속성별 다양성 계산 (1~3)
    diversity = zeros(1, 3);
    for k = 1:3
        values = {board.(fields{k})};
        diversity(k) = length(unique(values));  % 다양성 1~3
    end

    % 🔁 2. 기존 보드 카드 2장과 후보 1장으로 세트 가능한 조합 탐색
    for i = 1:length(board)
        for j = i+1:length(board)
            match = 0;
            match_type = strings(1, 3);  % 'same', 'diff', 'partial'

            for k = 1:3
                vals = {board(i).(fields{k}), board(j).(fields{k}), candidate.(fields{k})};
                num_unique = length(unique(vals));

                if num_unique == 1
                    match = match + 1;
                    match_type(k) = "same";
                elseif num_unique == 3
                    match = match + 1;
                    match_type(k) = "diff";
                else
                    match_type(k) = "partial";
                end
            end

            % ✅ 3. 진짜 세트라면 속성별 방식에 따라 위험도 가중
            if match == 3
                penalty = 0;
                for k = 1:3
                    if match_type(k) == "same"
                        % same: 다양성 낮을수록 위험 (역다양성)
                        penalty = penalty + (1 / diversity(k));
                    elseif match_type(k) == "diff"
                        % diff: 다양성 높을수록 위험
                        penalty = penalty + (diversity(k) / 3);  % 정규화
                    end
                end
                score = score + 100 * (penalty / 3);  % 속성별 평균 패널티
            elseif match == 2
                % 거의 세트: 약한 위험은 그대로 유지
                score = score + 1;
            end
        end
    end
end
