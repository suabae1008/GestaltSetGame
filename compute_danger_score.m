function score = compute_danger_score(candidate, board, mode)
% 후보 카드 candidate가 board에 들어갈 때의 세트 위험도 계산
% mode:
%   - 'simple'   : 버전 A. 세트 구성 여부만 기반 (기본값)
%   - 'diversity': 버전 B. 속성 다양성 고려 가중치 포함

    if nargin < 3
        mode = 'simple';
    end

    fields = fieldnames(candidate);  % 속성 이름 자동 감지
    num_fields = length(fields);
    score = 0;

    % 🟡 diversity 모드: 보드의 속성별 다양성 계산
    if strcmp(mode, 'diversity')
        diversity = zeros(1, num_fields);
        for k = 1:num_fields
            values = {board.(fields{k})};
            diversity(k) = length(unique(values));
        end
    end

    % 🔁 보드 내 2장씩 + 후보 조합을 통해 위험도 계산
    for i = 1:length(board)
        for j = i+1:length(board)
            match = 0;
            match_type = strings(1, num_fields);  % same / diff / partial

            for k = 1:num_fields
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

            if match == num_fields
                if strcmp(mode, 'simple')
                    score = score + 100;
                elseif strcmp(mode, 'diversity')
                    penalty = 0;
                    for k = 1:num_fields
                        if match_type(k) == "same"
                            penalty = penalty + (1 / diversity(k));
                        elseif match_type(k) == "diff"
                            penalty = penalty + (diversity(k) / 3);  % 정규화
                        end
                    end
                    score = score + 100 * (penalty / num_fields);  % 속성별 평균 패널티
                end
            elseif match == num_fields - 1
                % score = score + 1;  % "거의 세트" 점수 주려면 활성화
            end
        end
    end
end
