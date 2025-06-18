% 마우스 입력을 받고 정답인지 판별하는 함수

function [EndTime, error] = CheckMouseClicks(ans1, ans2, ans3)

% 오답 횟수 변수 설정
error = 0;

% 입력받은 인수를 이용해 카드 크기에 맞게 타겟 범위 지정하기
cardWidth = 150;
cardHeight = 200;
target1 = [ans1(1)-cardWidth, ans1(2)-cardHeight, ans1(1)+cardWidth, ans1(2)+cardHeight];
target2 = [ans2(1)-cardWidth, ans2(2)-cardHeight, ans2(1)+cardWidth, ans2(2)+cardHeight];
target3 = [ans3(1)-cardWidth, ans3(2)-cardHeight, ans3(1)+cardWidth, ans3(2)+cardHeight];

% break 전까지 반복해서 입력받고 정답 판별
while true

    % 타겟이 클릭되었는지 판별하는 변수
    targetInside = [false, false, false];

    % 마우스 입력을 받고 좌표 저장
    clickedPoints = zeros(3,2);
    for i = 1:3
        while true
            [x, y, buttons] = GetMouse();
            if any(buttons)
                clickedPoints(i,:) = [x, y];
                WaitSecs(0.1);
                break;
            end
        end

        % 중복 입력 방지
        while any(buttons)
            [~, ~, buttons] = GetMouse();
        end
    end

    % 클릭된 좌표와 타겟 범위 비교
    for i = 1:3
        clickedX = clickedPoints(i,1);
        clickedY = clickedPoints(i,2);
        
        if clickedX >= target1(1) && clickedX <= target1(3) && clickedY >= target1(2) && clickedY <= target1(4)
            targetInside(1) = true;

        elseif clickedX >= target2(1) && clickedX <= target2(3) && clickedY >= target2(2) && clickedY <= target2(4)
            targetInside(2) = true;
        
        elseif clickedX >= target3(1) && clickedX <= target3(3) && clickedY >= target3(2) && clickedY <= target3(4)
            targetInside(3) = true;
        
        end
    end
    
    % 모든 타겟이 클릭됐는지 확인
    allInside = all(targetInside);
    
    % 모든 타겟이 클릭된 경우
    if allInside == true

        % 끝난 시각 저장
        EndTime = GetSecs();

        % 정답을 알리는 소리 출력
        pahandle = PsychPortAudio('Open', [], 1, 1, 44100, 1);
        tone1 = MakeBeep(880, 0.1, 44100);  
        tone2 = MakeBeep(1760, 0.1, 44100); 
        soundData = [tone1, tone2];
        PsychPortAudio('FillBuffer', pahandle, soundData);
        PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);
        PsychPortAudio('Close', pahandle);

        % 반복문 종료
        break;

    % 모든 타겟이 클릭되지 않은 경우
    else

        % 오답 횟수 증가
        error = error + 1;

        % 오답을 나타내는 소리 출력
        pahandle = PsychPortAudio('Open', [], 1, 1, 44100, 1);
        tone = MakeBeep(500, 0.1, 44100);
        PsychPortAudio('FillBuffer', pahandle, tone);
        PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);
        PsychPortAudio('Close', pahandle);
    end
end

