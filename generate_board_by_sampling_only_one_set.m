%%



% 이거 버젼 여러개 있는 함수입니다 확인해주세요.
% 세트 카드 3개 정해놓고, 나머지 9개를 한꺼번에 랜덤 generate한 다음
% 1) 세트 개수가 1개가 아니면 9개 다시 뽑기
% 2) 세트를 많이 만드는 카드 순서대로 다른 걸로 교체하기


% [VER1] 세트카드 (3개) 추출 - 남은 카드 중 랜덤하게 9개 뽑음 - 세트 개수 확인 - 1개가 아니면 9개 한꺼번에 폐기 - 다시 랜덤하게 9개 뽑음 로직입니다

% function board = generate_board_by_sampling_only_one_set()
% 
%     max_attempts = 50;  % [최대 샘플링 횟수] 9개 카드 랜덤 추출 
% 
%     while true
% 
%         % 1. 유효한 세트 3장 생성
%         set_cards = generate_structured_valid_set();
%         
%         % 디버깅용: set cards 출력
%         fprintf('\n[SET 생성]\n');
%         for i = 1:3
%             fprintf('  카드%d: %s-%s-%s\n', i, ...
%                 set_cards(i).shape, set_cards(i).color, set_cards(i).pattern);
%         end
% 
%         % 2. 전체 카드 중 세트 3장 제거 - 후보 카드 생성
%         all_cards = generate_all_cards();
%         used_mask = ismember_structs(all_cards, set_cards);
% 
%         candidates = all_cards(~used_mask);
% 
%         % 3. 9장 무작위 샘플링 시도
%         for attempt = 1:max_attempts
% 
%             fprintf('==========Attempt %d===========\n', attempt);
% 
%             % 랜덤하게 인덱스 9개 뽑아서, 세트카드랑 합해 12개 보드 구성
%             sample_idx = randperm(length(candidates), 9);
%             board = [set_cards, candidates(sample_idx)];
% 
%             % 세트 개수 확인
%             set_count = count_sets(board);
% 
%             % 디버깅용: 세트 개수 확인 및 보드 카드 목록 출력
%             fprintf('[CHECK] 시도 #%d → 세트 개수: %d\n', attempt, set_count);
%             fprintf('\n[📋 전체 보드 카드 목록]\n');
%             for i = 1:length(board)
%                 fprintf('%2d: %s-%s-%s\n', i, ...
%                     board(i).shape, board(i).color, board(i).pattern);
%             end
%             
%             % 세트 개수 1개면 종료
%             if set_count == 1
%                 fprintf('[DONE] 보드 완성! 🎯 시도 #%d\n', attempt);
% 
%                 % 보드 출력
%                 fprintf('\n[📋 완성된 보드 카드 목록]\n');
%                 for i = 1:length(board)
%                     fprintf('%2d: %s-%s-%s\n', i, ...
%                         board(i).shape, board(i).color, board(i).pattern);
%                 end
% 
%                 return;
%             end
% 
%         end
% 
%         % max attempts 초과
%         fprintf('못 찾겠어요');
% 
%         return;
%     end
% end
%% 
% [VER2] 세트카드 (3개) 추출 - 남은 카드 중 랜덤하게 9개 뽑음 - 세트 개수 확인 
% - 1개가 아니면 카드 교체 시작
% - 카드 교체: 세트를 가장 많이 만드는 카드 순서대로 사용 안된 카드와 교체 (들어왔을 때 가장 안전한 카드로)



function board = generate_board_by_sampling_only_one_set(set_cards)

    max_attempts = 10;  % 9개 추가 후보 샘플링 최대 시도 횟수

    while true

        % 1. 유효한 세트 3장 생성
        % set_cards = generate_structured_valid_set();

        % 디버깅용 출력
        fprintf('\n[SET 생성]\n');
        for i = 1:3
            fprintf('  카드%d: %s-%s-%s-%s\n', i, ...
                set_cards(i).shape, set_cards(i).color, set_cards(i).pattern, set_cards(i).number);
        end

        % 2. 전체 카드 중 세트 3장 제거
        all_cards = generate_all_cards();
        used_mask = ismember_structs(all_cards, set_cards);

        candidates = all_cards(~used_mask); % working

        % 3. 9장 무작위 샘플링 시도
        for attempt = 1:max_attempts

            sample_idx = randperm(length(candidates), 9);
            board = [set_cards, candidates(sample_idx).'];

            % 4. 세트 개수 확인
            [set_count, set_indices] = count_sets_with_indices(board);

            fprintf('[CHECK] 시도 #%d → 세트 개수: %d\n', attempt, set_count);
    
            % 세트 개수 한 개면 종료
            if set_count == 1
                fprintf('[DONE] 보드 완성! 🎯 시도 #%d\n', attempt);

                % 보드 출력
                fprintf('\n[📋 완성된 보드 카드 목록]\n');
                for i = 1:length(board)
                    fprintf('%2d: %s-%s-%s\n', i, ...
                        board(i).shape, board(i).color, board(i).pattern);
                end
                return;
            end

            % 세트 개수 한개 아니라면
            % === [교체 루프 시작] ===
            fprintf('\n🔁 세트가 1개 초과이므로 교체 시도 시작...\n');
            
            % 고정 세트 카드 제외
            fixed_indices = 1:3;
            
            % 최대 교체 횟수 제한 (무한 루프 방지용)
            max_swaps = 10;
            swap_count = 0;
            
            while set_count > 1 && swap_count < max_swaps

                swap_count = swap_count + 1;
            
                % 1. 세트 등장 횟수 기준 정렬
                card_count = zeros(1, length(board));
                for i = 1:size(set_indices, 1)
                    for j = 1:3
                        card_count(set_indices(i, j)) = card_count(set_indices(i, j)) + 1;
                    end
                end
                [~, sorted_indices] = sort(card_count, 'descend');
            
                % 2. 가장 많이 포함된 (but 교체 가능) 카드 선택
                target_idx = -1;
                for i = 1:length(sorted_indices)
                    idx = sorted_indices(i);
                    if ~ismember(idx, fixed_indices) && card_count(idx) > 0
                        target_idx = idx;
                        break;
                    end
                end

                if target_idx == -1
                    fprintf('[!] 교체 가능한 카드가 없음\n');
                    break;
                end
            
                % 3. 후보 중 danger score가 가장 낮은 카드 선택
                board_candidates = all_cards(~ismember_structs(all_cards, board));

                best_score = inf;
                best_candidate = struct();
                best_candidate_idx = -1;
            
                for i = 1:length(board_candidates)
                    temp_board = board;
                    temp_board(target_idx) = board_candidates(i);
                    danger = compute_danger_score(board_candidates(i), temp_board, 'simple');
            
                    if danger < best_score
                        best_score = danger;
                        best_candidate = board_candidates(i);
                        best_candidate_idx = i;
                    end
                end
            
                % 4. 교체 수행
                fprintf('[SWAP %d] 카드 %d (%s-%s-%s) → 후보 %d (%s-%s-%s), 위험도 %.2f\n', ...
                    swap_count, ...
                    target_idx, board(target_idx).shape, board(target_idx).color, board(target_idx).pattern, ...
                    best_candidate_idx, best_candidate.shape, best_candidate.color, best_candidate.pattern, best_score);
            
              
                % 보드만 교체, 후보는 갱신하지 않음
                board(target_idx) = board_candidates(best_candidate_idx);       
                
            
                % 다시 세트 재계산
                [set_count, set_indices] = count_sets_with_indices(board);
                fprintf('[INFO] 교체 후 세트 개수: %d\n', set_count);

                if set_count == 1
                    fprintf('[DONE] 보드 완성! 🎯 시도 #%d\n', attempt);
    
                    % 보드 출력
                    fprintf('\n[📋 완성된 보드 카드 목록]\n');
                    for i = 1:length(board)
                        fprintf('%2d: %s-%s-%s-%s\n', i, ...
                            board(i).shape, board(i).color, board(i).pattern, board(i).number);
                    end
                    return;
                end

            end

        end

        % 9장을 max_attempts 내에 못 찾으면 세트부터 새로
        % fprintf('[RESET] %d회 시도 실패. 세트 새로 뽑습니다.\n', max_attempts);
        fprintf('못 찾겠어요');
        return;
    end
end

