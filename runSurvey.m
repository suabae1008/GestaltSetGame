function runSurvey()
    % Psychtoolbox 초기화
    Screen('Preference', 'SkipSyncTests', 2);
    [w, rect] = Screen('OpenWindow', 0, [255 255 255], [0 0 1080 720]);
    Screen('TextSize', w, 28);
    KbName('UnifyKeyNames');

    % 질문 및 입력 타입 설정
    questions = {
        '1. What is your age? (Type and press Enter)', ...
        '2. What is your gender? (Press M for Male / F for Female)', ...
        '3. Have you played SET game before? (Y/N)', ...
        '4. How often do you play puzzle games? (1:Never ~ 5:Very often)', ...
        ['5. What is your visual strategy?\n\n'  newline ...
         '   1. I quickly scan the whole picture' newline ...
         '   2. I sequentially check each part']
    };

    inputTypes = {'text', 'key', 'key', 'key', 'key'};
    validKeys = {{}, {'M','F'}, {'Y','N'}, {'1','2','3','4','5'}, {'1','2'}};
    labels = {{}, {'Male','Female'}, {'Yes','No'}, {}, {}};
    labels_confirm = {{},{'Male','Female'}, {'Yes','No'},...
        {'Never', 'Sometimes', 'Normal', 'Often', 'Very Often'},...
        {'Scan whole picture', 'Check each part'}};

    responses = cell(length(questions), 1);
    responses_confirm = cell(length(questions),1);

    % 질문 루프
    for q = 1:length(questions)
        if strcmp(inputTypes{q}, 'text')
            responses{q} = getTextInput(w, rect, questions{q});
            responses_confirm{q} = getTextInput(w, rect, questions{q});
        else
            responses{q} = getKeyInput(w, rect, questions{q}, validKeys{q}, labels{q});
            responses_confirm{q} = getKeyInput(w, rect, questions{q}, validKeys{q}, labels_confirm{q});
        end
    end

    % 확인 및 재입력
    confirmText = 'Please confirm your responses:\n\n';
    for i = 1:length(questions)
        confirmText = [confirmText, sprintf('Q%d: %s\n', i, responses_confirm{i})];
    end
    confirmText = [confirmText, '\n\nPress Y to confirm, N to restart'];

    while true
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, confirmText, 'center', 'center', [0 0 0]);
        Screen('Flip', w);
        KbWait;
        [~,~,kc] = KbCheck;
        key = KbName(find(kc));
        if iscell(key), key = key{1}; 
        end
        if strcmpi(key, 'Y')
            break;
        elseif strcmpi(key, 'N')
            Screen('CloseAll');
            runSurvey();  % 재시작
            return;
        end
    end

    % 저장
    resultFile = fopen('survey_result.txt', 'w');
    fprintf(resultFile, '==== Survey Result ====\n\n');
    disp('==== Survey Result ====');
    for i = 1:length(questions)
        fprintf('Q%d: %s\n', i, responses{i});
        fprintf(resultFile, 'Q%d: %s\n', i, responses{i});
    end
    fclose(resultFile);

    Screen('CloseAll');
    disp('Saved to survey_result.txt');
end

function inputText = getTextInput(w, rect, prompt)
    inputText = '';
    while true
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, prompt, 'center', rect(4)*0.4, [0 0 0]);
        DrawFormattedText(w, ['> ' inputText], 'center', rect(4)*0.5, [0 0 0]);
        Screen('Flip', w);

        ch = GetChar;
        if ch == 13 || ch == 3  % Enter
            if ~isempty(str2double(inputText)) && ~isnan(str2double(inputText))
                break;
            end
        elseif ch == 8 || ch == 127  % Backspace
            if ~isempty(inputText)
                inputText(end) = [];
            end
        elseif isstrprop(ch, 'digit')
            inputText = [inputText ch];
        end
    end
end

function result = getKeyInput(w, rect, prompt, validKeys, labels)
    while true
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, prompt, 'center', 'center', [0 0 0]);
        Screen('Flip', w);

        key = '';
        while isempty(key)
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                pressed = KbName(find(keyCode));
                if iscell(pressed)
                    key = upper(pressed{1});
                else
                    key = upper(pressed);
                end
            end
        end

        % 키 정규화: 숫자 키패드 대응
        if startsWith(key, 'KP_')
            key = extractAfter(key, 'KP_');
        elseif length(key) > 1 && key(end) == '!'
            key = key(1); % '1!' -> '1'
        end

        if isempty(validKeys) || any(strcmpi(key, validKeys))
            idx = find(strcmpi(key, validKeys), 1);
            if ~isempty(labels)
                result = labels{idx};
            else
                result = key;
            end
            break;
        end
    end
end