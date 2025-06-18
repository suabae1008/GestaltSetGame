% 카드 속성을 입력받아 그리는 함수

function generateCard(screen, shape, color, pattern, num, position)
    
    % 카드 배경 그리기
    cardWidth = 120;
    cardHeight = 140;
    cardPosition = [position(1)-cardWidth, position(2)-cardHeight, position(1)+cardWidth, position(2)+cardHeight];
    Screen('FillRect', screen, [255 255 255], cardPosition);
    Screen('FrameRect', screen, [0 0 0], cardPosition, 3);

    % 색 지정하기
    switch color
        case 'red'
            color = [255 0 0];
        case 'yellow'
            color = [0 200 0]; % 노란색이 잘 안보여서 초록색으로 변경
        case 'blue'
            color = [0 0 255];
    end
    
    % 개수에 따라 중심 좌표 재설정
    switch num
        case 'one'
            NumShapePos = [position(1), position(2)];
            num = 1;
        case 'two'
            NumShapePos = [position(1), position(2)+40; position(1), position(2)-40];
            num = 2;
        case 'three'
            NumShapePos = [position(1), position(2)+80; position(1), position(2);position(1), position(2)-80;];
            num = 3;
    end

    % 도형 크기 설정
    shapeWidth = 80;
    shapeHeight = 20;
    frameWidth = 10;
    
    %{
    도형 그리기 
    그리는 방식이 반복적이라 원만 코멘트 남깁니다.
    'empty'와 'filled'는 그리는 방식이 도형에 상관없이 같습니다. (삼각형 도형 위치 설정 제외)
    'shade'의 경우 :
    사각형은 마스크를 만들 필요가 없기 때문에
        줄무늬 이미지를 크기 재설정 후 바로 텍스쳐화 하고 테두리와 함께 그립니다.
    삼각형은 미리 만들어놓은 삼각형 내부 점 판별 함수를 이용해 마스크를 그린 후
        줄무늬 이미지와 마스크를 합친 텍스쳐를 생성한 뒤 테두리와 함께 그립니다.
    %}

    % 도형과 무늬를 구분하는 스위치-케이스
    switch shape
        case 'circle'
            switch pattern
                case 'empty'
                    
                    % 입력된 개수만큼 도형 그리기 반복
                    for i=1:num
                        
                        % 도형이 그려질 위치 설정
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        
                        % 안이 비어있는 도형 그리기
                        Screen('FrameOval', screen, color, shapePosition, frameWidth);
                    end
                case 'filled'
                    for i=1:num
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        
                        % 안이 채워져있는 도형 그리기
                        Screen('FillOval', screen, color, shapePosition);
                    end
                case 'shade'
                    % 마스크를 그릴 공간 설정
                    [X, Y] = meshgrid(1:200, 1:100);

                    % 원 범위 마스크 만들기
                    mask = ((X - 100)/100).^2 + ((Y - 50)/50).^2 <= 1;

                    % 미리 만들어놓은 함수를 통해 줄무늬 이미지 생성
                    img = generateStripe(screen, color);
                    
                    % 마스크 크기에 맞게 이미지 크기 재설정
                    img = img(1:100, :, :);

                    % 만들어놓은 마스크의 투명도 설정
                    alphaChannel = uint8(mask) * 255;

                    % 투명도 마스크와 줄무늬 이미지 합치기
                    img(:,:,4) = alphaChannel;

                    % 투명도가 작동하도록 설정
                    Screen('BlendFunction', screen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

                    % 마스크와 무늬를 합친 이미지 텍스쳐화
                    texture = Screen('MakeTexture', screen, img);

                    for i=1:num
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        
                        % 텍스쳐와 도형 테두리 그리기
                        Screen('DrawTexture', screen, texture, [], shapePosition);
                        Screen('FrameOval', screen, color, shapePosition, frameWidth);
                    end
                    

            end
        case 'square'
            switch pattern
                case 'empty'
                    for i=1:num
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        Screen('FrameRect', screen, color, shapePosition, frameWidth);
                    end
                case 'filled'
                    for i=1:num
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        Screen('FillRect', screen, color, shapePosition);
                    end
                case 'shade'
                    img = generateStripe(screen, color);
                    img = img(1:100, :, :);
                    texture = Screen('MakeTexture', screen, img);
                    for i=1:num
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        Screen('DrawTexture', screen, texture, [], shapePosition);
                        Screen('FrameRect', screen, color, shapePosition, frameWidth);
                    end
            end
            
        case 'triangle'
            switch pattern
                case 'empty'
                    for i=1:num
                        triPosition = [NumShapePos(i, 1), NumShapePos(i, 2)-shapeHeight; NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)+shapeHeight; NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        Screen('FramePoly', screen, color, triPosition, frameWidth);
                    end
                case 'filled'
                    for i=1:num
                        triPosition = [NumShapePos(i, 1), NumShapePos(i, 2)-shapeHeight; NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)+shapeHeight; NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        Screen('FillPoly', screen, color, triPosition);
                    end
                case 'shade'
                    [X, Y] = meshgrid(1:200, 1:100);
                    points = [X(:), Y(:)];
                    mask = isInTriangle(points, [100 0], [0 100], [200 100]);
                    img = generateStripe(screen, color);
                    img = img(1:100, :, :);
                    alphaChannel = uint8(mask) * 255;
                    img(:,:,4) = alphaChannel;
                    Screen('BlendFunction', screen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    texture = Screen('MakeTexture', screen, img);
                    for i=1:num
                        shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];    
                        triPosition = [NumShapePos(i, 1), NumShapePos(i, 2)-shapeHeight; NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)+shapeHeight; NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                        Screen('DrawTexture', screen, texture, [], shapePosition);
                        Screen('FramePoly', screen, color, triPosition, frameWidth);
                    end
                    
            end  
    end
end