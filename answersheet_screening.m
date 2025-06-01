% 1. 파일 목록 불러오기 (answersheet_only2로 시작하는 파일들)
files = dir('answersheet_only2*.mat');

% 2. 결과 저장용 빈 배열
concat_ans = [];

% 3. 파일 반복 처리
for i = 1:length(files)
    fprintf('🔄 Loading file: %s\n', files(i).name);
    
    % 파일 로드
    loaded = load(files(i).name);
    
    % ans 변수 확인
    if isfield(loaded, 'ans')
        data = loaded.ans;

        % 구조체인지 확인 후 누적
        if isstruct(data)
            concat_ans = [concat_ans; data(:)];  % 세로로 붙이기
            fprintf('✅ %d rows appended from %s\n', numel(data), files(i).name);
        else
            warning('⚠️ Variable "ans" in %s is not a struct. Skipped.', files(i).name);
        end
    else
        warning('⚠️ Variable "ans" not found in %s. Skipped.', files(i).name);
    end
end

% 4. 결과 요약
fprintf('📦 Total rows in concat_ans: %d\n', numel(concat_ans));

%%

% 결과 저장용 배열
screened_answer = [];

% 전체 row 순회
for i = 1:length(concat_ans)
    cards = concat_ans(i).cards;

    % 각 속성별 값 추출
    shapes   = {cards.shape};
    colors   = {cards.color};
    patterns = {cards.pattern};
    numbers  = {cards.number};

    % unique 개수 계산
    num_unique_shape   = numel(unique(shapes));
    num_unique_color   = numel(unique(colors));
    num_unique_pattern = numel(unique(patterns));
    num_unique_number  = numel(unique(numbers));

    % 중간 출력
    fprintf('Row %d: shape=%d, color=%d, pattern=%d, number=%d\n', ...
        i, num_unique_shape, num_unique_color, num_unique_pattern, num_unique_number);

    % 2개인 속성이 있는지 확인
    if any([num_unique_shape, num_unique_color, num_unique_pattern, num_unique_number] == 2)
        continue;  % skip 이 row
    end

    % 조건을 통과한 경우만 추가
    screened_answer = [screened_answer; concat_ans(i)];
end

% 최종 결과 요약
fprintf('✅ Total screened rows: %d\n', numel(screened_answer));

