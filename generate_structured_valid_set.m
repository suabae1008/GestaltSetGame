% function set_cards = generate_structured_valid_set()
%     % 속성 정의
%     attr_names = {'shape', 'color', 'pattern', 'number'};
%     attr_values = {
%         {'square', 'circle', 'triangle'}, ...
%         {'red', 'yellow', 'blue'}, ...
%         {'shade', 'empty', 'filled'}, ...
%         {'one', 'two', 'three'}
%     };
%     num_attrs = numel(attr_names);
% 
%     all_cards = generate_all_cards();  % 전체 카드 풀
%     raw_set = repmat(struct(), 1, 3);  % 빈 카드 3장
% 
%     while true
%         same_flags = randi([0, 1], 1, num_attrs);
%         if sum(same_flags) == num_attrs
%             continue;  % 모든 속성이 동일한 경우 패스
%         end
% 
%         % 속성 조합대로 3장 생성
%         for attr_idx = 1:num_attrs
%             options = attr_values{attr_idx};
%             field = attr_names{attr_idx};
%             if same_flags(attr_idx) == 1
%                 val = options{randi(3)};
%                 for k = 1:3
%                     raw_set(k).(field) = val;
%                 end
%             else
%                 vals = options(randperm(3));
%                 for k = 1:3
%                     raw_set(k).(field) = vals{k};
%                 end
%             end
%         end
%         % 필드 자동 감지 → 템플릿 구조체 생성
%         attr_names = fieldnames(all_cards);
%         empty_template = cell2struct(repmat({[]}, size(attr_names)), attr_names, 1);
%         
%         % set_cards 초기화: all_cards와 같은 필드로
%         set_cards = repmat(empty_template, 1, 3);
%         for k = 1:3
%             mask = ismember_structs(all_cards, raw_set(k));
%             idx = find(mask, 1);
%             if isempty(idx)
%                 error('카드 %d가 all_cards에 없음', k);
%             end
%             set_cards(k) = all_cards(idx);
%         end
% 
%         return;
%     end
% end


%% 
% 랜덤한 2개의 속성은 같고, 2개의 속성은 다르도록 세트 조합 결정
% function set_cards = generate_structured_valid_set()
%     % 속성 정의
%     attr_names = {'shape', 'color', 'pattern', 'number'};
%     attr_values = {
%         {'square', 'circle', 'triangle'}, ...
%         {'red', 'yellow', 'blue'}, ...
%         {'shade', 'empty', 'filled'}, ...
%         {'one', 'two', 'three'}
%     };
%     num_attrs = numel(attr_names);
% 
%     all_cards = generate_all_cards();  % 전체 카드 풀
%     raw_set = repmat(struct(), 1, 3);  % 빈 카드 3장
% 
%     while true
%         % 2개는 같고, 2개는 다르게 설정
%         same_flags = zeros(1, num_attrs);
%         same_idx = randperm(num_attrs, 2);
%         same_flags(same_idx) = 1;
% 
%         % 속성 조합대로 3장 생성
%         for attr_idx = 1:num_attrs
%             options = attr_values{attr_idx};
%             field = attr_names{attr_idx};
%             if same_flags(attr_idx) == 1
%                 val = options{randi(3)};
%                 for k = 1:3
%                     raw_set(k).(field) = val;
%                 end
%             else
%                 vals = options(randperm(3));
%                 for k = 1:3
%                     raw_set(k).(field) = vals{k};
%                 end
%             end
%         end
% 
%         % 필드 자동 감지 → 템플릿 구조체 생성
%         attr_names_all = fieldnames(all_cards);
%         empty_template = cell2struct(repmat({[]}, size(attr_names_all)), attr_names_all, 1);
% 
%         % set_cards 초기화: all_cards와 같은 필드로
%         set_cards = repmat(empty_template, 1, 3);
%         for k = 1:3
%             mask = ismember_structs(all_cards, raw_set(k));
%             idx = find(mask, 1);
%             if isempty(idx)
%                 error('카드 %d가 all_cards에 없음', k);
%             end
%             set_cards(k) = all_cards(idx);
%         end
% 
%         return;
%     end
% end


function set_cards = generate_structured_valid_set(num_same)
    % 속성 정의
    attr_names = {'shape', 'color', 'pattern', 'number'};
    attr_values = {
        {'square', 'circle', 'triangle'}, ...
        {'red', 'yellow', 'blue'}, ...
        {'shade', 'empty', 'filled'}, ...
        {'one', 'two', 'three'}
    };
    num_attrs = numel(attr_names);

    all_cards = generate_all_cards();  % 전체 카드 풀
    raw_set = repmat(struct(), 1, 3);  % 빈 카드 3장

    while true
        % num_same개 속성은 같고, 나머지는 다르게
        same_flags = zeros(1, num_attrs);
        same_idx = randperm(num_attrs, num_same);
        same_flags(same_idx) = 1;

        for attr_idx = 1:num_attrs
            options = attr_values{attr_idx};
            field = attr_names{attr_idx};
            if same_flags(attr_idx) == 1
                val = options{randi(3)};
                for k = 1:3
                    raw_set(k).(field) = val;
                end
            else
                vals = options(randperm(3));
                for k = 1:3
                    raw_set(k).(field) = vals{k};
                end
            end
        end

        attr_names_all = fieldnames(all_cards);
        empty_template = cell2struct(repmat({[]}, size(attr_names_all)), attr_names_all, 1);

        set_cards = repmat(empty_template, 1, 3);
        for k = 1:3
            mask = ismember_structs(all_cards, raw_set(k));
            idx = find(mask, 1);
            if isempty(idx)
                error('카드 %d가 all_cards에 없음', k);
            end
            set_cards(k) = all_cards(idx);
        end

        return;
    end
end
