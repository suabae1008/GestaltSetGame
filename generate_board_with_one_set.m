% function board = generate_board_with_one_set()
%     max_attempts = 1000;  % 무한루프 방지
% 
%     while true
%         % 1. 유효한 세트 3장 생성
%         set_cards = generate_structured_valid_set();
%         fprintf('[SET 생성]\n')
%         for i = 1:3
%             fprintf('  카드%d: %s-%s-%s\n', i, ...
%                 set_cards(i).shape, set_cards(i).color, set_cards(i).pattern);
%         end
% 
%         % 2. 전체 카드 풀 생성
%         all_cards = generate_all_cards();
% 
%         % 3. 세트 카드 제외한 후보 카드 풀 만들기
%         used_mask = ismember_structs(all_cards, set_cards);
%         candidates = all_cards(~used_mask);
% 
%         % 4. 초기 보드에 세트 카드 넣기
%         board = set_cards;
% 
%         % 5. 후보 카드 각각 위험도 점수 계산
%         for i = 1:length(candidates)
% %             fprintf('[SCORE] 후보 idx=%d 계산 중: %s-%s-%s\n', ...
% %                 i, candidates(i).shape, candidates(i).color, candidates(i).pattern);
%             candidates(i).score = compute_danger_score(candidates(i), board);
%         end
% 
%         % 6. 위험도 낮은 순서로 후보 정렬
%         [~, idx_sorted] = sort([candidates.score]);
%         candidates = candidates(idx_sorted);
% 
%         % 7. 정렬된 후보들 중에서 세트 안 생기게 9장 추가
%         for i = 1:length(candidates)
%             candidate = candidates(i);
%             if ~would_create_set(candidate, board)
%                 % 필드 정리: score 없는 구조체로 정제해서 넣기
%                 candidate_clean = rmfield(candidate, 'score');
%                 board(end+1) = candidate_clean;
% 
%                 fprintf('[ADD] %d번째 카드 추가됨: %s-%s-%s\n', ...
%                     length(board), candidate_clean.shape, ...
%                     candidate_clean.color, candidate_clean.pattern);
%                 
%             end
%             if length(board) == 12
%                 fprintf('[DONE] 보드 완성 🎉\n');
%                 return  % 성공
%             end
%         end
% 
%         % 실패한 경우 다시 처음부터
%     end
% end



%% 
function board = generate_board_with_one_set()
    max_attempts = 1000;  % 9장 구성 시도 횟수 제한

    while true
        % 1. 세트 3장 생성 (고정)
        set_cards = generate_structured_valid_set();
        fprintf('[SET 생성]\n');
        for i = 1:3
            fprintf('  카드%d: %s-%s-%s\n', i, ...
                set_cards(i).shape, set_cards(i).color, set_cards(i).pattern);
        end

        % 2. 전체 카드 목록에서 세트 제외
        all_cards = generate_all_cards();
        used_mask = ismember_structs(all_cards, set_cards);
        candidates_all = all_cards(~used_mask);

        % ✨ 세트 고정 후 여러 번 시도
        for attempt = 1:max_attempts
            fprintf('[TRY #%d] 9장 구성 시도 중...\n', attempt);
            board = set_cards;

            % 후보 카드 danger score 초기 계산
            for i = 1:length(candidates_all)
                candidates_all(i).score = compute_danger_score(candidates_all(i), board);
            end

            % 무작위 섞은 뒤 위험도 순으로 정렬
            idx_shuffle = randperm(length(candidates_all));
            candidates = candidates_all(idx_shuffle);
            [~, idx_sorted] = sort([candidates.score]);
            candidates = candidates(idx_sorted);

            % 1장씩 추가하면서 danger score 동적 갱신
            i = 1;
            while length(board) < 12 && i <= length(candidates)
                candidate = candidates(i);
                if ~would_create_set(candidate, board)
                    % 카드 추가
                    candidate_clean = rmfield(candidate, 'score');
                    board(end+1) = candidate_clean;
                    fprintf('[ADD] %d번째 카드 추가됨: %s-%s-%s\n', ...
                        length(board), candidate_clean.shape, ...
                        candidate_clean.color, candidate_clean.pattern);

                    % 남은 후보 danger score 갱신
                    for j = i+1:length(candidates)
                        if ~ismember_structs(candidates(j), board)
                            candidates(j).score = compute_danger_score(candidates(j), board);
                        end
                    end
                    % 재정렬
                    remaining = candidates(i+1:end);
                    [~, idx_sorted] = sort([remaining.score]);
                    candidates(i+1:end) = remaining(idx_sorted);
                end
                i = i + 1;
            end

            if length(board) == 12
                fprintf('[DONE] 보드 완성 🎉\n');
                return;
            else
                fprintf('[RETRY] 실패, 세트 유지하고 재시도...\n');
            end
        end

        % 1000번 시도해도 안 되면 세트 바꿔서 다시
        fprintf('[RESET] 1000회 시도 실패. 세트 새로 뽑습니다.\n');
    end
end
