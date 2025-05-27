%{
입력 인수 정리
screen : 사용할 윈도우 포인터 입력
shape : 'circle', 'triangle', 'rectangle'
color : 'red', 'yellow', 'blue'
pattern : 'fill', 'frame', 'stripe'
num : '1', '2', '3'
position : 그림이 그려질 정 중앙 좌표 (카드 크기는 300*400)
ex) [1280 800] 입력시 카드는 [1130 600 1430 1000]에 그려짐
%}

function generateCard(screen, shape, color, pattern, num, position)
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
    
    % 개수 만들기
    switch num
        case 1
            NumShapePos = [position(1), position(2), position(1), position(2)];
        case 2
            NumShapePos = [position(1), position(2)+80; position(1), position(2)-80];
        case 3
            NumShapePos = [position(1), position(2)+120; position(1), position(2);position(1), position(2)-120;];
    end

    % 도형 그리기
    shapeWidth = 100;
    shapeHeight = 50;


    %shapePosition = [position(1)-shapeWidth, position(2)-shapeHeight, position(1)+shapeWidth, position(2)+shapeHeight];
    %triPosition = [position(1), position(2)-shapeHeight; position(1)-shapeWidth, position(2)+shapeHeight; position(1)+shapeWidth, position(2)+shapeHeight];
    
    switch shape
        case 'circle'
            switch pattern
                case 'frame'
                    for i=1:num
                    shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('FrameOval', screen, color, shapePosition, 5);
                    end
                case 'fill'
                    for i=1:num
                    shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('FillOval', screen, color, shapePosition);
                    end
                case 'stripe'
                    [X, Y] = meshgrid(1:200, 1:100);
                    mask = ((X - 100)/100).^2 + ((Y - 50)/50).^2 <= 1;
                    img = generateStripe(screen, color);
                    img = img(1:100, :, :);
                    alphaChannel = uint8(mask) * 255;
                    img(:,:,4) = alphaChannel;
                    Screen('BlendFunction', screen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    texture = Screen('MakeTexture', screen, img);
                    for i=1:num
                    shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('DrawTexture', screen, texture, [], shapePosition);
                    Screen('FrameOval', screen, color, shapePosition, 5);
                    end
                    

            end
        case 'rectangle'
            switch pattern
                case 'frame'
                    for i=1:num
                    shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('FrameRect', screen, color, shapePosition, 5);
                    end
                case 'fill'
                    for i=1:num
                    shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('FillRect', screen, color, shapePosition);
                    end
                case 'stripe'
                    img = generateStripe(screen, color);
                    img = img(1:100, :, :);
                    texture = Screen('MakeTexture', screen, img);
                    for i=1:num
                    shapePosition = [NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)-shapeHeight, NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('DrawTexture', screen, texture, [], shapePosition);
                    Screen('FrameRect', screen, color, shapePosition, 5);
                    end
            end
            
        case 'triangle'
            switch pattern
                case 'frame'
                    for i=1:num
                    triPosition = [NumShapePos(i, 1), NumShapePos(i, 2)-shapeHeight; NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)+shapeHeight; NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('FramePoly', screen, color, triPosition, 5);
                    end
                case 'fill'
                    for i=1:num
                    triPosition = [NumShapePos(i, 1), NumShapePos(i, 2)-shapeHeight; NumShapePos(i, 1)-shapeWidth, NumShapePos(i, 2)+shapeHeight; NumShapePos(i, 1)+shapeWidth, NumShapePos(i, 2)+shapeHeight];
                    Screen('FillPoly', screen, color, triPosition);
                    end
                case 'stripe'
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
                    Screen('FramePoly', screen, color, triPosition, 5);
                    end
                    
            end  
    end
end