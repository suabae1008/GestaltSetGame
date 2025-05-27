function exmain()
    Screen('Preference','SkipSyncTests', 1);
    [windowPtr, rect] = Screen('OpenWindow', 0, [150 150 150], [0 0 2560 1600]);
    InitializePsychSound(1);
    generateCard(windowPtr, 'triangle', 'red', 'stripe', 3, [1280 800]);
    generateCard(windowPtr,'circle', 'yellow', 'fill', 2, [900 600]);
    generateCard(windowPtr,'rectangle', 'blue', 'frame', 1, [1600 700]);

    StartTime = Screen('Flip', windowPtr);

    [EndTime, error] = CheckMouseClicks([1280 800], [900 600], [1600 700]);

    RT = EndTime - StartTime;

    disp(RT)
    disp(error)

    KbStrokeWait;
    sca;
end
