function InstructionSlides(windowPtr, instructionImages)
    % 슬라이드 개수
    numSlides = length(instructionImages);
    currentIndex = 1;

    while true
        % 이미지 불러오기 및 텍스처 생성
        img = imread(instructionImages{currentIndex});
        texture = Screen('MakeTexture', windowPtr, img);

        % 이미지와 안내 텍스트 함께 출력
        Screen('DrawTexture', windowPtr, texture, [], []);
        DrawFormattedText(windowPtr, 'Press Enter to continue, Backspace to go back', ...
                          'center', 1000, [0 0 0]);
        Screen('Flip', windowPtr);
        Screen('Close', texture);  % 텍스처 제거 (메모리 절약)

        % 키 입력 대기 및 릴리즈
        [~, keyCode] = KbStrokeWait;
        KbReleaseWait;

        % 누른 키 확인
        keyPressed = KbName(find(keyCode));
        if iscell(keyPressed)
            keyPressed = keyPressed{1};  % 여러 키가 동시에 눌렸을 경우 첫 번째만 사용
        end

        % 키에 따라 동작 분기
        switch keyPressed
            case 'Return'  % 다음 슬라이드
                if currentIndex < numSlides
                    currentIndex = currentIndex + 1;
                else
                    break;  % 마지막 슬라이드 → 종료
                end
            case 'BackSpace'  % 이전 슬라이드
                if currentIndex > 1
                    currentIndex = currentIndex - 1;
                end
        end
    end
end
