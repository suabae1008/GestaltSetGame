function runSurvey()
    % Psychtoolbox 초기화
    Screen('Preference', 'SkipSyncTests', 2);
    [w, rect] = Screen('OpenWindow', 0, [255 255 255], [0 0 1080 720]);
    Screen('TextSize', w, 28);
    KbName('UnifyKeyNames');
    
    %설문 시작 안내
    openingText = 'Please answer the survey with insturcted keys'
    DrawFormattedText(w,openingText,'center','center', [0 0 0]);
	Screen('Flip', w);
	WaitSecs(3);
    Screen('Flip', w);

    % 질문 및 입력 타입 설정
    questions = {
        '1. What is your age? (Type and press Enter)', ...
        '2. What is your gender? (Press M for Male / F for Female)', ...
        '3. Have you played SET game before? (Y/N)', ...
        '4. How often do you play puzzle games? (1:Never ~ 5:Very often)', ...
        ['5. What is your visual strategy?\n'  newline ...
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

    % 질문 답 루프
 for q = 1:length(questions)
    if strcmp(inputTypes{q}, 'text')
        responses{q} = getTextInput(w, rect, questions{q});
        responses_confirm{q} = responses{q}; 
    else
        responses{q} = getKeyInput(w, rect, questions{q}, validKeys{q}, labels{q});
        idx = find(strcmpi(responses{q}, validKeys{q}), 1);
        if ~isempty(idx) && ~isempty(labels_confirm{q})
            responses_confirm{q} = labels_confirm{q}{idx};  % 확인용 label로 저장
        else
            responses_confirm{q} = responses{q};  % fallback
        end
    end
end

% 확인 및 재입력 텍스트 구성
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
        fprintf('Q%d: %s\n', i, responses_confirm {i});
        fprintf(resultFile, 'Q%d: %s\n', i, responses{i});
    end
    fclose(resultFile);
    
    % 설문 완료 메세지 
    closingText = 'Thank you for your answers. Test will be begin'
    DrawFormattedText(w,closingText,'center','center', [0 0 0]);
	Screen('Flip', w);
	WaitSecs(2);
    Screen('CloseAll');
    disp('Saved to survey_result.txt');
end

%1번 문항 input
function inputText = getTextInput(w, rect, prompt)
    inputText = '';
    KbName('UnifyKeyNames');
    
    while true
        % 입력 화면 갱신
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, prompt, 'center', rect(4)*0.4, [0 0 0]);
        DrawFormattedText(w, ['>> ' inputText], 'center', rect(4)*0.5, [0 0 0]);
        Screen('Flip', w);

        % 키 입력 대기
        while true
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                key = KbName(find(keyCode,1));
                if iscell(key), key = key{1}; end
                break;
            end
        end
        while KbCheck; end

        % 키패드 숫자 처리
        if startsWith(key, 'KP_')
            key = extractAfter(key, 'KP_');
        end

        % 동작 처리
        if strcmp(key, 'Return') || strcmp(key, 'Enter')
            if ~isempty(inputText) && ~isnan(str2double(inputText))
                break;
            end
        elseif strcmp(key, 'BackSpace')
            if ~isempty(inputText)
                inputText(end) = [];
            end
        elseif any(strcmp(key, {'0','1','2','3','4','5','6','7','8','9'}))
            inputText = [inputText key];
        end
    end
end

%2~5번문항 input
function result = getKeyInput(w, rect, prompt, validKeys, labels)
    inputDisplay = '';
    inputKey = '';
    confirmed = false;

    KbName('UnifyKeyNames');

    while ~confirmed
        % 화면 표시
        Screen('FillRect', w, [255 255 255]);
        DrawFormattedText(w, prompt, 'center', rect(4)*0.4, [0 0 0]);
        DrawFormattedText(w, ['>> ' inputDisplay], 'center', rect(4)*0.6, [0 0 0]);
        Screen('Flip', w);

        % 키 입력 대기
        key = '';
        while isempty(key)
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                key = KbName(find(keyCode,1));
                if iscell(key)
                    key = key{1};
                end
                key = upper(key);
                while KbCheck; end  % 키가 놓일 때까지 대기
            end
        end

        % 키패드 숫자 처리
        if startsWith(key, 'KP_')
            key = extractAfter(key, 'KP_');
        end

        % 동작 분기
        if strcmp(key, 'RETURN') || strcmp(key, 'ENTER')
            % Enter 키 입력 → 이전에 입력된 키를 확정
            if ~isempty(inputKey)
                if isempty(validKeys) || any(strcmpi(inputKey, validKeys))
                    idx = find(strcmpi(inputKey, validKeys), 1);
                    if ~isempty(labels) && ~isempty(idx)
                        result = labels{idx};
                    else
                        result = inputKey;
                    end
                    confirmed = true;
                end
            end
        elseif strcmp(key, 'BACKSPACE')
            inputKey = '';
            inputDisplay = '';
        elseif isempty(validKeys) || any(strcmpi(key, validKeys))
            % 유효 키 입력 → 화면에 표시만 (아직 확정 아님)
            inputKey = key;
            inputDisplay = key;
        end

        WaitSecs(0.15);  % 연속 입력 방지
    end
end
