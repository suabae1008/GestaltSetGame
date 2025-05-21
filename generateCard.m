%{
입력 인수 정리
screen : 사용할 윈도우 포인터 입력
shape : 'circle', 'triangle', 'rectangle'
color : 'red', 'yellow', 'blue'
pattern : 'fill', 'frame', 'stripe'
position : 그림이 그려질 정 중앙 좌표 (카드 크기는 300*400)
ex) [1280 800] 입력시 카드는 [1130 600 1430 1000]에 그려짐
%}
function generateCard(screen, shape, color, pattern, position)
    % 카드 배경 만들기
    cardWidth = 150;
    cardHeight = 200;
    cardPosition = [position(1)-cardWidth, position(2)-cardHeight, position(1)+cardWidth, position(2)+cardHeight];
    Screen('FillRect', screen, [255 255 255], cardPosition);
    Screen('FrameRect', screen, [0 0 0], cardPosition, 3);

    % 색 지정하기
    switch color
        case 'red'
            color = [255 0 0];
        case 'yellow'
            color = [255 255 0];
        case 'blue'
            color = [0 0 255];
    end

    % 도형 그리기
    shapeWidth = 100;
    shapeHeight = 100;
    shapePosition = [position(1)-shapeWidth, position(2)-shapeHeight, position(1)+shapeWidth, position(2)+shapeHeight];
    triPosition = [position(1), position(2)-shapeHeight; position(1)-shapeWidth, position(2)+shapeHeight; position(1)+shapeWidth, position(2)+shapeHeight];
    
    switch shape
        case 'circle'
            switch pattern
                case 'frame'
                    Screen('FrameOval', screen, color, shapePosition, 5);
                case 'fill'
                    Screen('FillOval', screen, color, shapePosition);
                case 'stripe'
                    [X, Y] = meshgrid(1:200, 1:200);
                    mask = (X-100).^2 + (Y-100).^2 <= 10000;
                    img = generateStripe(screen, color);
                    alphaChannel = uint8(mask) * 255;
                    img(:,:,4) = alphaChannel;
                    Screen('BlendFunction', screen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    texture = Screen('MakeTexture', screen, img);
                    Screen('DrawTexture', screen, texture, [], shapePosition);
                    Screen('FrameOval', screen, color, shapePosition, 5);

            end
        case 'rectangle'
            switch pattern
                case 'frame'
                    Screen('FrameRect', screen, color, shapePosition, 5);
                case 'fill'
                    Screen('FillRect', screen, color, shapePosition);
                case 'stripe'
                    img = generateStripe(screen, color);
                    texture = Screen('MakeTexture', screen, img);
                    Screen('DrawTexture', screen, texture, [], shapePosition);
                    Screen('FrameRect', screen, color, shapePosition, 5);
            end
            
        case 'triangle'
            switch pattern
                case 'frame'
                    Screen('FramePoly', screen, color, triPosition, 5);
                case 'fill'
                    Screen('FillPoly', screen, color, triPosition);
                case 'stripe'
                    [X, Y] = meshgrid(1:200, 1:200);
                    points = [X(:), Y(:)];
                    mask = isInTriangle(points, [100 0], [0 200], [200 200]);
                    img = generateStripe(screen, color);
                    alphaChannel = uint8(mask) * 255;
                    img(:,:,4) = alphaChannel;
                    Screen('BlendFunction', screen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    texture = Screen('MakeTexture', screen, img);
                    Screen('DrawTexture', screen, texture, [], shapePosition);
                    Screen('FramePoly', screen, color, triPosition, 5);
            end  
    end
end
