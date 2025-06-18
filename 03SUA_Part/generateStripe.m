% 줄무늬 이미지 만드는 함수

function img = generateStripe(screen, color)
    
    % 화면에 출력되지 않을 offscreen 열기
    offscreen = Screen('OpenOffscreenWindow', screen, [255 255 255 255], [0, 0, 200, 200]);
    
    % 사각형 영역에 줄무늬 하나하나 그리기
    for i = 20:40:200
        Screen('DrawLine', offscreen, color, +i, 0, 0, +i, 10);
        Screen('DrawLine', offscreen, color, 200-i, 200, 200, 200-i, 10);
    end
    
    % 그린 줄무늬를 이미지로 저장
    img = Screen('GetImage', offscreen, [], 'backBuffer');

    % 투명도 채널 만들기
    img(:,:,4) = 255;
end