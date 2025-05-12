function img = generateStripe(screen, color)
    offscreen = Screen('OpenOffscreenWindow', screen, [255 255 255 255], [0, 0, 200, 200]);
    for i = 20:40:200
        Screen('DrawLine', offscreen, color, +i, 0, 0, +i, 10);
        Screen('DrawLine', offscreen, color, 200-i, 200, 200, 200-i, 10);
    end

    img = Screen('GetImage', offscreen, [], 'backBuffer');
    img(:,:,4) = 255;
end