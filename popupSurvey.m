function popupSurvey()
    % 질문 내용 설정
    prompts = {
        '1. 나이를 입력해주세요:' ...
        '2. 성별을 입력해주세요 (남/여 또는 M/F):' ...
        '3. SET 게임을 플레이 해본 적이 있나요? (Y/N):' ...
        '4. 퍼즐 게임을 자주 하시나요? (1: 전혀 ~ 5: 매우 자주):' ...
        ['5. 시각적 처리 전략은?' ...
         '  1. 전체를 빠르게 훑는다' ...
         '  2. 일부분부터 차례로 확인한다' ...
         '  3. 비슷해 보이는 것끼리 묶어본다']};

    dlg_title = '설문 응답 입력';
    num_lines = 1;
    defaultans = {'', '', '', '', ''};

    % 팝업창 띄우기
    answer = inputdlg(prompts, dlg_title, num_lines, defaultans);

    % 사용자가 취소한 경우 처리
    if isempty(answer)
        disp('사용자가 설문을 취소했습니다.');
        return;
    end

    % 응답 저장
    survey = struct();
    survey.age = str2double(answer{1});
    survey.gender = lower(strtrim(answer{2}));
    survey.setPlayed = upper(strtrim(answer{3}));
    survey.puzzleFreq = str2double(answer{4});
    survey.visualStrategy = str2double(answer{5});

    % 결과 요약 텍스트 생성
    summaryText = sprintf(['응답을 확인해주세요:\n\n' ...
        '1. 나이: %d\n2. 성별: %s\n3. SET 경험: %s\n4. 퍼즐 빈도: %d\n' ...
        '5. 전략 유형: %d'], ...
        survey.age, survey.gender, survey.setPlayed, ...
        survey.puzzleFreq, survey.visualStrategy);

    % 확인 다이얼로그
    choice = questdlg(summaryText, ...
        '응답 확인 및 저장', ...
        '저장', '다시 입력', '취소', '저장');

    switch choice
        case '저장'
            save('popup_survey_result.mat', 'survey');
            disp('설문 결과가 popup_survey_result.mat 파일로 저장되었습니다.');
        case '다시 입력'
            popupSurvey();  % 재귀 호출로 다시 입력
        otherwise
            disp('설문이 저장되지 않았습니다.');
    end
end
