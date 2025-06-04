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

        Screen('FillRect', windowPtr, [150 150 150],[0 0 1920 1080]); %회색바탕 생성
        Screen('Flip', windowPtr);
        
        %% 위치 지정 (3x4)
        numMap = containers.Map({'one','two','three','four'}, {1, 2, 3, 4});
        [xGrid, yGrid] = meshgrid(300:450:1650, 200:330:860);
        positions = [xGrid(:), yGrid(:)];

        %% 연습 문제 (screened 데이터 사용)
        practiceData = load('fin_ans.mat');
        practiceProblems = practiceData.ans.Prac;
        practiceProblemsAns = practiceData.ans.PracAns;

        DrawFormattedText(windowPtr, ['Lets start practice trial.\n'...
            ' If your answer is correct, you can hear high beep sound.\n'...
            'Press any key to start'], 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait;

        for trialIdx = 1:2
            card_set = practiceProblems{1,trialIdx};
            for j = 1:12
                card = card_set(j,:);
                generateCard(windowPtr, card{1}, card{2}, card{3}, numMap(card{4}), positions(j,:));
            end

            correctCardIndices = practiceProblemsAns{trialIdx};
            StartTime = Screen('Flip', windowPtr);
            
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

        instructionImages = {'Images/instruction-6.png'};
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
                cardpositions = {[525 170]; [815 170]; [1105 170]; [1395 170]; [525 540]; [815 540]; [1105 540]; [1395 540]; [525 910]; [815 910]; [1105 910]; [1395 910]};
            case '1'
                cardpositions = {[565 210]; [815 210]; [1105 210]; [1355 210]; [565 540]; [815 540]; [1105 540]; [1355 540]; [565 870]; [815 870]; [1105 870]; [1355 870]};
            case '2'
                cardpositions = {[585 170]; [835 170]; [1085 170]; [1335 170]; [585 540]; [835 540]; [1085 540]; [1335 540]; [585 910]; [835 910]; [1085 910]; [1335 910]};
            case '3'
                cardpositions = {[565 210]; [815 210]; [1105 170]; [1355 170]; [565 540]; [815 540]; [1105 540]; [1355 540]; [565 910]; [815 910]; [1105 870]; [1355 870]};
        end

        % 셔플하여 앞 5, 뒤 5 문제로 분할
        shuffledIdx = randperm(8);
        firstSetIdx = shuffledIdx(1:3);
        secondSetIdx = shuffledIdx(4:6);
        thirdSetIdx = shuffledIdx(7:8);

        % 실험용 전체 문제 구성 (3 + 연습 + 3 + 연습 + 2)
        combinedProblems = [allProblems(firstSetIdx), allProblems(9), allProblems(secondSetIdx), allProblems(10), allProblems(thirdSetIdx)];
        combinedAns = [allAns(firstSetIdx), allAns(9), allAns(secondSetIdx), allAns(10), allAns(thirdSetIdx)];

        trialNum = 10;
        
        % 원래 문제 번호를 기록하는 배열
        combinedOriginalIndices = [firstSetIdx, -1, secondSetIdx, -2, thirdSetIdx];  
        
        % isingroup 적용: 결과는 1x10 logical vector
        withinGroupFlags = isingroup(responses.group, combinedOriginalIndices);


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
            trialData(trialIdx).original_problem_index = combinedOriginalIndices(trialIdx);
            trialData(trialIdx).correct_indices = correctCardIndices;
            trialData(trialIdx).response_time = EndTime - StartTime;
            trialData(trialIdx).error = err;

            % 추가: 그룹 내 여부 저장
            trialData(trialIdx).within_group = withinGroupFlags(trialIdx);

            DrawFormattedText(windowPtr, 'Press any key for next trial', 'center', 'center', [0 0 0]);
            Screen('Flip', windowPtr);
            KbStrokeWait;
        end

        participant_id = ['P' datestr(now, 'yyyymmdd_HHMMSS')];
        filename = [responses.subNum '_' participant_id '_results.mat'];

        results = struct();
        results.participant_id = participant_id;
        results.responses = responses;
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
