%{
switch responses.group
    case 'C'
        cardPositions = {[525 170]; [815 170]; [1105 170]; [1395 170]; [525 540]; [815 540]; [1105 540]; [1395 540]; [525 910]; [815 910]; [1105 910]; [1395 910]};
    case '1'
        cardPositions = {[565 210]; [815 210]; [1105 210]; [1355 210]; [565 540]; [815 540]; [1105 540]; [1355 540]; [565 870]; [815 870]; [1105 870]; [1355 870]};
    case '2'
        cardPositions = {[585 170]; [835 170]; [1085 170]; [1335 170]; [585 540]; [835 540]; [1085 540]; [1335 540]; [585 910]; [835 910]; [1085 910]; [1335 910]};
    case '3'
        cardPositions = {[565 210]; [815 210]; [1105 170]; [1355 170]; [565 540]; [815 540]; [1105 540]; [1355 540]; [565 910]; [815 910]; [1105 870]; [1355 870]};
end
%}

function main()
    try
        Screen('Preference','SkipSyncTests', 1);
        [windowPtr, rect] = Screen('OpenWindow', 0, [255 255 255], [0 0 2560 1600]);
        InitializePsychSound(1);

        %% 설문조사 실행
        responses = runSurvey(windowPtr, rect);
        WaitSecs(2);
        Screen('FillRect', windowPtr, [150 150 150],[0 0 2560 1600]);
        Screen('Flip', windowPtr);

        %% 위치 지정 (3x4)
        numMap = containers.Map({'one','two','three','four'}, {1, 2, 3, 4});
        [xGrid, yGrid] = meshgrid(300:450:1650, 200:330:860);
        positions = [xGrid(:), yGrid(:)];

        %% 연습 문제 (screened 데이터 사용)
        practiceData = load('answersheet_screened.mat');
        practiceProblems = practiceData.screened_answer;  % 예시 인덱스 1, 2

        DrawFormattedText(windowPtr, 'Lets start practice trial. Press any key to start', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait;

        for trialIdx = 1:2
            card_set = practiceProblems(trialIdx).cards;
            practice_case = cell(1,12);

            for j = 1:12
                card = card_set(j);
                practice_case{j} = {card.shape, card.color, card.pattern, numMap(card.number)};
            end

            correctCards = practice_case(1:3);
            wrongCards = practice_case(4:12);
            allCards = [correctCards, wrongCards];
            shuffledIdx = randperm(12);
            shuffledCards = allCards(shuffledIdx);

            for k = 1:12
                params = shuffledCards{k};
                generateCard(windowPtr, params{1}, params{2}, params{3}, params{4}, positions(k,:));
            end
            StartTime = Screen('Flip', windowPtr);

            correctCardIndices = [];
            for n = 1:12
                for m = 1:3
                    if isequal(shuffledCards{n}, correctCards{m})
                        correctCardIndices(end+1) = n;
                        break;
                    end
                end
            end

            [EndTime, err] = CheckMouseClicks(positions(correctCardIndices(1),:), ...
                                              positions(correctCardIndices(2),:), ...
                                              positions(correctCardIndices(3),:));

            disp(['[연습] Trial ', num2str(trialIdx), ' - RT: ', num2str(EndTime - StartTime), ', Error: ', num2str(err)]);

            if trialIdx < 2
                DrawFormattedText(windowPtr, 'Press any key for next practice trial.', 'center', 'center', [0 0 0]);
                Screen('Flip', windowPtr); KbStrokeWait;
            end
        end

        DrawFormattedText(windowPtr, 'Practice is over. Press any key to move on', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr); KbStrokeWait;

        %% 실험 데이터
        data = load('answersheet.mat');
        practice_problems = data.ans;
        final_cases_for_test = cell(10,12);

        trialNum = 1;
        RTs = zeros(1, trialNum);
        errors = zeros(1, trialNum);
        trialData(trialNum) = struct();

        for trialIdx = 1:trialNum
            card_set = practice_problems(trialIdx).cards;
            for j = 1:12
                card = card_set(j);
                final_cases_for_test{trialIdx,j} = {card.shape, card.color, card.pattern, numMap(card.number)};
            end
            correctCards = final_cases_for_test(trialIdx, 1:3);
            wrongCards = final_cases_for_test(trialIdx, 4:12);
            allCards = [correctCards, wrongCards];
            shuffledIdx = randperm(12);
            shuffledCards = allCards(shuffledIdx);

            for k = 1:12
                params = shuffledCards{k};
                generateCard(windowPtr, params{1}, params{2}, params{3}, params{4}, positions(k,:));
            end
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

            [EndTime, err] = CheckMouseClicks(positions(correctCardIndices(1),:), ...
                                              positions(correctCardIndices(2),:), ...
                                              positions(correctCardIndices(3),:));
            RTs(trialIdx) = EndTime - StartTime;
            errors(trialIdx) = err;
            disp(['Trial ', num2str(trialIdx), ' - RT: ', num2str(RTs(trialIdx)), ', Error: ', num2str(err)]);

            trialData(trialIdx).trial_index = trialIdx;
            trialData(trialIdx).correct_indices = correctCardIndices;
            trialData(trialIdx).response_time = RTs;
            trialData(trialIdx).error = err;
            trialData(trialIdx).card_order = shuffledCards;

            DrawFormattedText(windowPtr, 'Press any key for next trial', 'center', 'center', [0 0 0]);
            Screen('Flip', windowPtr);
            KbStrokeWait;
        end

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

    catch ME
        sca;  % 화면 안전하게 종료
        disp(getReport(ME));  % 에러 정보 출력
    end
end
