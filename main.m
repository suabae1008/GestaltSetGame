function main()
    Screen('Preference','SkipSyncTests', 1);
    [windowPtr, rect] = Screen('OpenWindow', 0, [150 150 150], [0 0 2560 1600]);
    generateCard(windowPtr, 'triangle', 'yellow', 'fill', [1280 800]);
    generateCard(windowPtr,'circle', 'red', 'stripe', [900 600]);

    Screen('Flip', windowPtr);
    KbStrokeWait;
    sca;
end
