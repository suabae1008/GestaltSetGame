function main()
    try
        %% 환경 설정
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
        InstructionSlides(windowPtr, instructionImages); % InstructionSlides함수로 화면에 사진 띄우기
        DrawFormattedText(windowPtr, 'Instruction complete. Press any key to start practice trial', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait; % 키보드 입력시 시작
        WaitSecs(2);

        Screen('FillRect', windowPtr, [150 150 150],[0 0 1920 1080]); % 회색바탕 생성, 화면 1920 x 1080
        Screen('Flip', windowPtr);
        
        %% 연습문제 위치 지정 (3x4)
        numMap = containers.Map({'one','two','three','four'}, {1, 2, 3, 4});
        [xGrid, yGrid] = meshgrid(300:450:1650, 200:330:860);
        positions = [xGrid(:), yGrid(:)];

        %% 연습 문제
        practiceData = load('fin_ans.mat'); % 사전 제작된 'fin_ans.mat'파일의 데이터 불러오기
        practiceProblems = practiceData.ans.Prac; % practiceData.ans.Prac에 저장된 연습문제 2개의 카드정보 불러오기
        practiceProblemsAns = practiceData.ans.PracAns;% practiceData.ans.Prac에 저장된 연습문제 2개의 정답카드 위치정보 불러오기

        DrawFormattedText(windowPtr, ['Lets start practice trial.\n'...
            ' If your answer is correct, you can hear high beep sound.\n'...
            'Press any key to start'], 'center', 'center', [0 0 0]); % 연습문제 시작 전 안내
        Screen('Flip', windowPtr);
        KbStrokeWait; % 키보드 입력시 시작

        for trialIdx = 1:2 % 2회의 연습문제
            card_set = practiceProblems{1,trialIdx};
            for j = 1:12 % 12장의 카드
                card = card_set(j,:);
                generateCard(windowPtr, card{1}, card{2}, card{3}, numMap(card{4}), positions(j,:)); % generateCard로 카드 띄우기
            end

            correctCardIndices = practiceProblemsAns{trialIdx}; % 연습문제의 정답카드 위치 (3 x 1의 double형 숫자배열)
            StartTime = Screen('Flip', windowPtr);
            
            [EndTime, err] = CheckMouseClicks(positions(correctCardIndices(1),:), ...
                                              positions(correctCardIndices(2),:), ...
                                              positions(correctCardIndices(3),:)); % CheckMouseClicks 함수를 이용해서 정답 여부 확인

            disp(['[연습] Trial ', num2str(trialIdx), ' - RT: ', num2str(EndTime - StartTime), ', Error: ', num2str(err)]);

            if trialIdx < 2 % 연습문제 넘어가기
                DrawFormattedText(windowPtr, 'Press any key for next practice trial.', 'center', 'center', [0 0 0]);
                Screen('Flip', windowPtr);
                KbStrokeWait;
            end
        end

        %% 실제 실험 전 설명
        DrawFormattedText(windowPtr, 'Practice is complete. Press any key to move on', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr); 
        KbStrokeWait; % 키보드 입력

        instructionImages = {'Images/instruction-6.png'};
        InstructionSlides(windowPtr, instructionImages); % InstructionSlides 함수 사용하여 사전 설명 이미지 띄우기

        DrawFormattedText(windowPtr, 'All preparations are complete.\n After you press any key, The test will begin in 5seconds.\n Good Luck! ', 'center', 'center', [0 0 0]);
        Screen('Flip', windowPtr);
        KbStrokeWait; % 키보드 입력시 시작
        WaitSecs(5);

        %% 실험 데이터
        data = load('fin_ans.mat'); % 본 실험 문제 설정을 위한 자료 불러오기
        allProblems = data.ans.prob;
        allAns = data.ans.ans;

        
        % 카드 위치 (Survey의 결과에 따라라 카드 위치 지정)
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

        
        %% 셔플하여 3,3,2로 나누기
        % 1~8까지의 original_problem_index값을 섞는다고 이해하시면 됩니다
        shuffledIdx = randperm(8);
        firstSetIdx = shuffledIdx(1:3);
        secondSetIdx = shuffledIdx(4:6);
        thirdSetIdx = shuffledIdx(7:8);

        %% 실험용 전체 문제 구성 (3 + 연습 + 3 + 연습 + 2)
        % allProblems의 9~10번 문항은 환기문항 추후 분석에서 모두 제외하고 분석합니다
        combinedProblems = [allProblems(firstSetIdx), allProblems(9), allProblems(secondSetIdx), allProblems(10), allProblems(thirdSetIdx)];
        combinedAns = [allAns(firstSetIdx), allAns(9), allAns(secondSetIdx), allAns(10), allAns(thirdSetIdx)];

        trialNum = 10; % 본 실험 문제 수
        
        %% 원래 문제 번호를 기록하는 배열 (추후 분석을 위하여)
        combinedOriginalIndices = [firstSetIdx, -1, secondSetIdx, -2, thirdSetIdx];  
        
        %% isingroup 적용: 결과는 1x10 logical vector (그룹 내외에 정답 SET가 위치하는지 여부)
        withinGroupFlags = isingroup(responses.group, combinedOriginalIndices);

        % 반응 시간 및 오답 수 측정을 기록하기 위한 자료형
        RTs = zeros(1, trialNum);
        errors = zeros(1, trialNum);

        trialData(trialNum) = struct();

        for trialIdx = 1:trialNum % 10번동안 반복
            card_set = combinedProblems{1,trialIdx};
            for j = 1:12 % 12장 카드
                card = card_set(j,:);
                generateCard(windowPtr, card{1}, card{2}, card{3}, numMap(card{4}), cardpositions{j}); % generateCard 함수로 카드 보여주기
            end
            StartTime = Screen('Flip', windowPtr); % RT 측정
            correctCardIndices = combinedAns{trialIdx}; % 정답 카드 위치

            [EndTime, err] = CheckMouseClicks(cardpositions{correctCardIndices(1)}, ...
                                              cardpositions{correctCardIndices(2)}, ...
                                              cardpositions{correctCardIndices(3)}); % cardpositions가 1 x 12의 cell 배열
            RTs(trialIdx) = EndTime - StartTime; % 시간 측정
            errors(trialIdx) = err; % 오답수 측정, 기록
            disp(['Trial ', num2str(trialIdx), ' - RT: ', num2str(RTs(trialIdx)), ', Error: ', num2str(err)]);

            % 결과 저장
            trialData(trialIdx).trial_index = trialIdx;
            trialData(trialIdx).original_problem_index = combinedOriginalIndices(trialIdx);
            trialData(trialIdx).correct_indices = correctCardIndices;
            trialData(trialIdx).response_time = EndTime - StartTime;
            trialData(trialIdx).error = err;

            %% 추가: 그룹 내외 여부 저장
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