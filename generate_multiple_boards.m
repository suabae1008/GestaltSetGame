function boards = generate_multiple_boards(n, m)
% 2-same 세트 n개, 1-same 세트 m개 생성

    if nargin < 1
        n=5;
        m=5;
    end
    total = n + m;
    boards = repmat(struct('cards', [], 'set_type', ''), 1, total);
    count = 0;

    fprintf('[생성 시작] 2-same %d개, 1-same %d개\n', n, m);

    % 1. 2-same 보드 n개 생성
    for i = 1:n
        while true
            try
                set_cards = generate_structured_valid_set(2);
                board = generate_board_by_sampling_only_one_set(set_cards);
                count = count + 1;
                boards(count).cards = board;
                boards(count).set_type = '2-same';
                fprintf('[%d/%d] 2-same 보드 생성 완료\n', count, total);
                break;
            catch
                % 실패 시 반복
            end
        end
    end

    % 2. 1-same 보드 m개 생성
    for i = 1:m
        while true
            try
                set_cards = generate_structured_valid_set(1);
                board = generate_board_by_sampling_only_one_set(set_cards);
                count = count + 1;
                boards(count).cards = board;
                boards(count).set_type = '1-same';
                fprintf('[%d/%d] 1-same 보드 생성 완료\n', count, total);
                break;
            catch
                % 실패 시 반복
            end
        end
    end

    fprintf('\n✅ 모든 보드 생성 완료: 총 %d개\n', total);
end
