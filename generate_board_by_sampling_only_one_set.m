function board = generate_board_by_sampling_only_one_set()
    max_attempts = 10000;  % 후보 샘플링 최대 시도 횟수

    while true
        % 1. 유효한 세트 3장 생성
        set_cards = generate_structured_valid_set();
        
        fprintf('\n[SET 생성]\n');
        for i = 1:3
            fprintf('  카드%d: %s-%s-%s\n', i, ...
                set_cards(i).shape, set_cards(i).color, set_cards(i).pattern);
        end

        % 2. 전체 카드 중 세트 3장 제거
        all_cards = generate_all_cards();
        used_mask = ismember_structs(all_cards, set_cards);

        % 디버깅용: used_mask 출력
        fprintf('[used_mask] ');
        fprintf('%d ', used_mask);
        fprintf('\n');

        candidates = all_cards(~used_mask);

        % 3. 9장 무작위 샘플링 시도
        for attempt = 1:max_attempts
            sample_idx = randperm(length(candidates), 9);
            board = [set_cards, candidates(sample_idx)];

            % 4. 세트 개수 확인
            num_sets = count_sets(board);
            fprintf('[CHECK] 시도 #%d → 세트 개수: %d\n', attempt, num_sets);

            fprintf('\n[📋 보드 카드 목록]\n');
            for i = 1:length(board)
                fprintf('%2d: %s-%s-%s\n', i, ...
                    board(i).shape, board(i).color, board(i).pattern);
            end

            if num_sets == 1
                fprintf('[DONE] 보드 완성! 🎯 시도 #%d\n', attempt);

                % 보드 출력
                fprintf('\n[📋 보드 카드 목록]\n');
                for i = 1:length(board)
                    fprintf('%2d: %s-%s-%s\n', i, ...
                        board(i).shape, board(i).color, board(i).pattern);
                end
                return;
            end
        end

        % 9장을 max_attempts 내에 못 찾으면 세트부터 새로
        fprintf('[RESET] %d회 시도 실패. 세트 새로 뽑습니다.\n', max_attempts);
    end
end
