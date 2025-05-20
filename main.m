function main()
    Screen('Preference','SkipSyncTests', 1);
    [windowPtr, rect] = Screen('OpenWindow', 0, [150 150 150], [0 0 2560 1600]);
    InitializePsychSound(1);
    generateCard(windowPtr, 'triangle', 'yellow', 'fill', [1280 800]);
    generateCard(windowPtr,'circle', 'red', 'stripe', [900 600]);
    generateCard(windowPtr,'rectangle', 'blue', 'frame', [1600 700]);

    Screen('Flip', windowPtr);

    [RT, error] = CheckMouseClicks([1280 800], [900 600], [1600 700]);
    disp(RT)
    disp(error)

    KbStrokeWait;
    sca;
end
