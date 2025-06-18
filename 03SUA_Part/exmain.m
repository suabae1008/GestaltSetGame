% 함수 작동을 확인하기 위한 메인 함수 예시

function exmain()

    % 화면 및 소리 기본 설정
    Screen('Preference','SkipSyncTests', 1);
    [windowPtr, rect] = Screen('OpenWindow', 0, [150 150 150], [0 0 1920 1080]);
    InitializePsychSound(1);
    
    % 실험군 별로 카드 좌표 설정
    responses.group = 'C';
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

    % 미리 저장한 문제 불러오기
    AnswerSheet = AnswerSheet_generate();
    
    % 문제를 제시하는 반복문
    for i = 1:10
        
        % AnswerSheet에 저장되어있는 카드 속성을 꺼내오기 위한 변수 설정
        fieldName = sprintf('prob%d', i);
        ansName = sprintf('ans%d', i);
        ansProperty = AnswerSheet.(fieldName);
        ansNum = AnswerSheet.(ansName);
        
        % 카드 그리는 반복문
        for j = 1:12

            % 미리 만들어놓은 함수를 이용해 카드 그리기
            generateCard(windowPtr, ansProperty{j, 1}, ansProperty{j, 2}, ansProperty{j, 3}, ansProperty{j, 4}, cardPositions{j});
        end

        % 화면에 카드를 출력하며 동시에 시작시간 저장
        StartTime = Screen('Flip', windowPtr);
        
        % 미리 만들어놓은 함수를 이용해 끝나는 시간과 오답 횟수 저장
        [EndTime, error] = CheckMouseClicks(cardPositions{ansNum(1)}, cardPositions{ansNum(2)}, cardPositions{ansNum(3)});

        % 응답 시간 계산
        RT = EndTime - StartTime;
    end
        
    % 응답 시간과 오답 횟수 출력
    disp(RT)
    disp(error)

    % 아무 키나 입력시 스크린 종료
    KbStrokeWait;
    sca;
end
