function [EndTime, error] = CheckMouseClicks(ans1, ans2, ans3)
error = 0;

cardWidth = 120;
cardHeight = 140;
target1 = [ans1(1)-cardWidth, ans1(2)-cardHeight, ans1(1)+cardWidth, ans1(2)+cardHeight];
target2 = [ans2(1)-cardWidth, ans2(2)-cardHeight, ans2(1)+cardWidth, ans2(2)+cardHeight];
target3 = [ans3(1)-cardWidth, ans3(2)-cardHeight, ans3(1)+cardWidth, ans3(2)+cardHeight];

while true
    targetInside = [false, false, false];
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
        while any(buttons)
            [~, ~, buttons] = GetMouse();
        end
    end

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

    allInside = all(targetInside);

    if allInside == true
        EndTime = GetSecs();
        tone1 = MakeBeep(880, 0.1, 44100);  
        tone2 = MakeBeep(1760, 0.1, 44100); 
        
        soundData = [tone1, tone2];
        
        pahandle = PsychPortAudio('Open', [], 1, 1, fs, 1);
        PsychPortAudio('FillBuffer', pahandle, soundData);
        PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);
        PsychPortAudio('Close', pahandle);
        break;
    else
        error = error + 1;
        pahandle = PsychPortAudio('Open', [], 1, 1, 44100, 1);
        tone = MakeBeep(500, 0.1, 44100);
        PsychPortAudio('FillBuffer', pahandle, tone);
        PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);
        PsychPortAudio('Close', pahandle);
    end
end

