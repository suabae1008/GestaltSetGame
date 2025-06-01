function main()
    Screen('Preference','SkipSyncTests', 1);
    [windowPtr, rect] = Screen('OpenWindow', 0, [255 255 255], [0 0 2560 1600]);
    InitializePsychSound(1);
%
    %% 설문조사 실행
    responses = runSurvey(windowPtr, rect);
    WaitSecs(2);
    Screen('FillRect', windowPtr, [150 150 150],[0 0 2560 1600]);
    Screen('Flip', windowPtr);

    %% 카드 조건 불러오기
    data = load('answersheet.mat');
    problems = data.ans;
    numMap = containers.Map({'one','two','three','four'}, {1, 2, 3, 4});
    final_cases_for_test = cell(10,12);

    % 위치 지정 (3x4)
    [xGrid, yGrid] = meshgrid(300:450:1650, 200:330:860);
    positions = [xGrid(:), yGrid(:)];
    
    %Trial 수 지정 (중요)
    trialNum = 3;

    %실험 초기화
    RTs = zeros(1, trialNum);
    errors = zeros(1, trialNum);
    trialData(trialNum) = struct();

    % 모든 문제 반복
    for trialIdx = 1:trialNum
        card_set = problems(trialIdx).cards;
        for j = 1:12
            card = card_set(j);
            final_cases_for_test{trialIdx,j} = {card.shape, card.color, card.pattern, numMap(card.number)};
        end
        % 1~3번 카드 = 정답
        correctCards = final_cases_for_test(trialIdx, 1:3);
        % 4~12번 카드 = 오답
        wrongCards = final_cases_for_test(trialIdx, 4:12);
        % 정답 + 오답 합치기 (총 12장)
        allCards = [correctCards, wrongCards];

        % 무작위 순서 생성
        shuffledIdx = randperm(12);
        shuffledCards = allCards(shuffledIdx);

        % 카드 그리기
        for k = 1:12
            params = shuffledCards{k};
            generateCard(windowPtr, params{1}, params{2}, params{3}, params{4}, positions(k,:));
        end

        % Flip 및 정답 인덱스 계산
        StartTime = Screen('Flip', windowPtr);
        correctCardIndices = [];

        for n = 1:length(shuffledCards)
            for m = 1:length(correctCards)
                if isequal(shuffledCards{n}, correctCards{m})
                    correctCardIndices(end+1) = n;
                    break;
                end
            end
        end

        % 정답 확인 (클릭 또는 키보드로 넘어가기)
        [EndTime, error] = CheckMouseClicks(positions(correctCardIndices(1),:), ...
                                             positions(correctCardIndices(2),:), ...
                                             positions(correctCardIndices(3),:));

        RTs(trialIdx) = EndTime - StartTime;
        error(trialIdx) = error;
        disp(['Trial ', num2str(trialIdx), ' - RT: ', num2str(RTs(trialIdx)), ', Error: ', num2str(error)]);
        
        trialData(trialIdx).trial_index = trialIdx;
        trialData(trialIdx).correct_indices = correctCardIndices;
        trialData(trialIdx).response_time = RTs;
        trialData(trialIdx).error = error;
        trialData(trialIdx).card_order = shuffledCards;  % 카드 정보 저장

        % 키 누를 때까지 대기 후 다음 trial
        DrawFormattedText(windowPtr, 'Press any key for next trial', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait;
    end
        %% 실험 결과 저장
       participant_id = ['P' datestr(now, 'yyyymmdd_HHMMSS')];
       filename = [responses.subNum '_' participant_id '_results.mat'];

       results = struct();
       results.participant_id = participant_id;
       results.responses = responses;
       results.RTs = RTs;
       results.errors = errors;
       results.trials = trialData;

       save(filename, 'results');
    
       sca;

end
