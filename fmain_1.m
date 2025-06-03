function main()
    try
        Screen('Preference','SkipSyncTests', 1);
        [windowPtr, rect] = Screen('OpenWindow', 0, [255 255 255], [0 0 1920 1080]);
        InitializePsychSound(1);
        ListenChar(2);

        %% 설문조사 실행
        responses = runSurvey(windowPtr, rect);
        WaitSecs(2);

        %% SET 게임 설명
        instructionImages = {
        'Images/instruction-1.png',
        'Images/instruction-2.png',
        'Images/instruction-3.png',
        'Images/instruction-4.png',
        'Images/instruction-5.png'
        };
        InstructionSlides(windowPtr, instructionImages);
        DrawFormattedText(windowPtr, 'Instruction complete. Press any key to start practice trial', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait;
        WaitSecs(2);

        Screen('FillRect', windowPtr, [150 150 150],[0 0 1920 1080]);
        Screen('Flip', windowPtr);

        %% 위치 지정 (3x4)
        numMap = containers.Map({'one','two','three','four'}, {1, 2, 3, 4});
        [xGrid, yGrid] = meshgrid(300:450:1650, 200:330:860);
        positions = [xGrid(:), yGrid(:)];

        %% 연습 문제 (screened 데이터 사용)
        practiceData = load('answersheet_screened.mat');
        practiceProblems = practiceData.screened_answer;

        DrawFormattedText(windowPtr, ['Lets start practice trial.\n'...
            ' If your answer is correct, you can hear high beep sound.\n'...
            'Press any key to start'], 'center', 'center', [0 0 0]);
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

        %% 실제 실험 전 설명
        DrawFormattedText(windowPtr, 'Practice is complete. Press any key to move on', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr); 
        KbStrokeWait;

        instructionImages = {'Images/instruction-4.png'};
        InstructionSlides(windowPtr, instructionImages);

        DrawFormattedText(windowPtr, 'All preparations are complete.\n After you press any key, The test will begin in 5seconds.\n Good Luck! ', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait;
        WaitSecs(5);

        %% 실험 데이터
        data = load('fin_ans.mat');
        allProblems = data.ans.prob;
        allAns = data.ans.ans;

        % 카드 위치
        switch responses.group
            case 'C'
                cardPositions = {[450 160]; [790 160]; [1130 160]; [1470 160]; [450 540]; [790 540]; [1130 540]; [1470 540]; [450 920]; [790 920]; [1130 920]; [1470 920]};
            case '1'
                cardPositions = {[450 240]; [710 240]; [1210 240]; [1470 240]; [450 540]; [710 540]; [1210 540]; [1470 540]; [450 840]; [710 840]; [1210 840]; [1470 840]};
            case '2'
                cardPositions = {[560 160]; [820 160]; [1090 160]; [1350 160]; [560 540]; [820 540]; [1090 540]; [1350 540]; [560 920]; [820 920]; [1090 920]; [1350 920]};
            case '3'
                cardPositions = {[450 160]; [710 160]; [1210 160]; [1470 160]; [450 460]; [710 460]; [1210 620]; [1470 620]; [450 920]; [710 920]; [1210 920]; [1470 920]};
        end

        % 셔플하여 앞 5, 뒤 5 문제로 분할
        shuffledIdx = randperm(8);
        firstSetIdx = shuffledIdx(1:3);
        secondSetIdx = shuffledIdx(4:6);
        thirdSetIdx = shuffledIdx(7:8);

        % 연습 문제 불러오기
        practiceProblems = data.ans.Prac;
        practiceProbAns = data.ans.PracAns;

        % 실험용 전체 문제 구성 (3 + 연습 + 3 + 연습 + 2)
        combinedProblems = [allProblems(firstSetIdx), practiceProblems(1), allProblems(secondSetIdx), practiceProblems(2), allProblems(thirdSetIdx)];
        combinedAns = [allAns(firstSetIdx), practiceProbAns(1), allAns(secondSetIdx), practiceProbAns(2), allAns(thirdSetIdx)];

        trialNum = 10;
        RTs = zeros(1, trialNum);
        errors = zeros(1, trialNum);
        trialData(trialNum) = struct();

        for trialIdx = 1:trialNum
            card_set = combinedProblems{1,trialIdx};
            for j = 1:12
                card = card_set(j,:);
                generateCard(windowPtr, card{1}, card{2}, card{3}, numMap(card{4}), cardpositions{j});
            end
            StartTime = Screen('Flip', windowPtr);
            correctCardIndices = combinedAns{trialIdx};

            [EndTime, err] = CheckMouseClicks(cardpositions{correctCardIndices(1)}, ...
                                              cardpositions{correctCardIndices(2)}, ...
                                              cardpositions{correctCardIndices(3)});
            RTs(trialIdx) = EndTime - StartTime;
            errors(trialIdx) = err;
            disp(['Trial ', num2str(trialIdx), ' - RT: ', num2str(RTs(trialIdx)), ', Error: ', num2str(err)]);

            trialData(trialIdx).trial_index = trialIdx;
            trialData(trialIdx).correct_indices = correctCardIndices;
            trialData(trialIdx).response_time = RTs(trialIdx);
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
        sca;
        disp(getReport(ME));
    end
    ListenChar(0);
    ShowCursor;
end
