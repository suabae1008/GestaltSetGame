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

    responses = cell(length(questions), 1);

    % 질문 루프
    for q = 1:length(questions)
        if strcmp(inputTypes{q}, 'text')
            responses{q} = getTextInput(w, rect, questions{q});
        else
            responses{q} = getKeyInput(w, rect, questions{q}, validKeys{q}, labels{q});
        end
    end

    % 확인 및 재입력
    confirmText = 'Please confirm your responses:\n\n';
    for i = 1:length(questions)
        confirmText = [confirmText, sprintf('Q%d: %s\n', i, responses{i})];
    end
    confirmText = [confirmText, '\n\nPress Y to confirm, N to restart'];

    while true
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, confirmText, 'center', 'center', [0 0 0]);
        Screen('Flip', w);
        KbWait;
        [~,~,kc] = KbCheck;
        key = KbName(find(kc));
        if iscell(key), key = key{1}; end
        if strcmpi(key, 'Y')
            break;
        elseif strcmpi(key, 'N')
            Screen('CloseAll');
            runSurvey();  % 재시작
            return;
        end
    end

    % 구조체로 저장
    survey.age = responses{1};
    survey.gender = responses{2};
    survey.setPlayed = responses{3};
    survey.puzzleFreq = responses{4};
    survey.visualStrategy = responses{5};

    save('surveyResult.mat', 'survey');
    Screen('CloseAll');
    disp('Survey saved to surveyResult.mat');
    disp(survey);
end

%% 입력 함수: 서술형 텍스트 입력
function inputText = getTextInput(w, rect, prompt)
    inputText = '';
    while true
        % 입력화면 그리기
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

%% 입력 함수: 키보드 단일키 입력
function result = getKeyInput(w, rect, prompt, validKeys, labels)
    while true
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, prompt, 'center', 'center', [0 0 0]);
        Screen('Flip', w);
        KbWait;
        [~,~,kc] = KbCheck;
        key = KbName(find(kc));
        if iscell(key), key = key{1}; end
        key = upper(key);

        if isempty(validKeys) || any(strcmpi(key, validKeys))
            if isempty(labels)
                result = key;
            else
                idx = find(strcmpi(key, validKeys));
                result = labels{idx};
            end
            break;
        end
    end
end
