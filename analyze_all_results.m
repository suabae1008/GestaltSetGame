function analyze_all_results(folderName)
    % 모든 .mat 파일을 읽고 trials + responses 정보 병합하여 분석 수행
    files = dir(fullfile(folderName, '*.mat'));
    allData = [];

    % 상위 폴더에 결과 저장 폴더 생성
    parentFolder = fileparts(folderName);  
    saveFolder = fullfile(parentFolder, 'analysis_results');
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end

    % 각 파일에 대한 데이터 추출 및 통합
    for i = 1:length(files)
        fileData = load(fullfile(parentFolder, files(i).name)); %구조체 접근
        varNames = fieldnames(fileData);
        data = fileData.(varNames{1});

        % trials struct 배열 → table
        trials = struct2table(data.trials);
        
        % !!환기문제 제거!!
        trials = trials(~ismember(trials.original_problem_index, [-1,-2]), :);
        nTrials = height(trials);

        % responses: 구조체 → 변수 추가
        R = data.responses;
        trials.participant_id = repmat({data.participant_id}, nTrials, 1);
        trials.group = repmat({R.group}, nTrials, 1);
        trials.age = repmat(R.age, nTrials, 1);
        trials.gender = repmat({R.gender}, nTrials, 1);
        trials.SET_experience = repmat(R.SET_experience, nTrials, 1);
        trials.game_frequency = repmat({R.game_frequency}, nTrials, 1);
        trials.strategy = repmat({R.strategy}, nTrials, 1);

        allData = [allData; trials]; %전체 데이터에 추가
    end

    % 이상치 제거용 IQR 정의
    isOutlier = @(x) x < (quantile(x,0.25) - 1.5*iqr(x)) | x > (quantile(x,0.75) + 1.5*iqr(x));
    allData.outlier = isOutlier(allData.response_time);

    % 분석 결과 저장용 테이블
    summaryStats = table;

    %% 기본 정보: 참가자 요약 (실험군, 나이, 성별, 게임 빈도, 전략 기준)
    %기본 분석방법:
    %[groupCounsts, 분석그룹] = gropucounts(allData.분석그룹); : 같은그룹 항목개수 확인
    %groupTable = table(분석그룹, 분석내용counts/8, table 열 이름 지정);
    %*데이터를 참가자 수로 환산해야하기 때문에 counnt를 8(실제문제 개수)로 나누어야함


    % 1. 실험군별 참가자 수
    [groupCounts, groupNames] = groupcounts(allData.group);
    groupTable = table(groupNames, groupCounts/8, ...
    'VariableNames', {'Group', 'ParticipantCount'});
    disp('실험군별 참가자 수:');
    disp(groupTable);

    % 2. 나이별 참가자 수
    [ageCounts, ageGroups] = groupcounts(allData.age);
    ageTable = table(ageGroups, ageCounts/8, ...
    'VariableNames', {'Age', 'ParticipantCount'});
    disp('나이별 참가자 수:');
    disp(ageTable);

    % 3. 성별 참가자 수
    [genderCounts, genderGroups] = groupcounts(allData.gender);
    genderTable = table(genderGroups, genderCounts/8, ...
    'VariableNames', {'Gender', 'ParticipantCount'});
    disp('성별 참가자 수:');
    disp(genderTable);

    % 4. 게임 빈도(game_frequency) 문항별 응답자 수
    [freqCounts, freqLabels] = groupcounts(allData.game_frequency);
    freqTable = table(freqLabels, freqCounts/8, ...
    'VariableNames', {'GameFrequency', 'ParticipantCount'});
    disp('게임 빈도 문항별 응답자 수:');
    disp(freqTable);

    % 5.전략(strategy) 문항별 응답자 수 (예: Visual strategy whole vs part)
    [stratCounts, stratLabels] = groupcounts(allData.strategy);
    stratTable = table(stratLabels, stratCounts/8, ...
    'VariableNames', {'Strategy', 'ParticipantCount'});
    disp('전략 문항별 응답자 수:');
    disp(stratTable);

    %% 분석 1: 그룹 내 vs 외 반응시간 및 정확도 비교
    within = allData(allData.within_group==1, :);
    between = allData(allData.within_group==0, :);
    
    %반응 시간, 정확도 비교 (ttest 이용)
    [~, p_rt] = ttest2(within.response_time, between.response_time);
    [~, p_acc] = ttest2(within.error, between.error==0);
    M_within_r = mean(within.response_time);
    M_between_r = mean(between.response_time);
    M_within_a = mean(within.error);
    M_between_a = mean(between.error);

    fprintf('Group Within vs Between:\n');
    fprintf('Response time mean: Within = %4f  Between = %4f\n',M_within_r, M_between_r );
    fprintf('Accuaracy mean: Within = %4f  Between = %4f\n',M_within_a, M_between_a );
    fprintf('Response Time p = %.4f\nAccuracy p = %.4f\n\n', p_rt, p_acc);


    %% 분석 2: 설문 변수별 반응 시간 차이 (age, frequency, strategy)
    g1 = findgroups(allData.age);
    g2 = findgroups(allData.game_frequency);
    g3 = findgroups(allData.strategy);

    %나이, 게임횟수, 분석전략별 반응시간 차이(anova이용)
    [p_age, tbl_age, ~] = anova1(allData.response_time, g1, 'off');
    [p_freq, tbl_freq, ~] = anova1(allData.response_time, g2, 'off');
    [p_strat, tbl_strat, ~] = anova1(allData.response_time, g3, 'off');

    fprintf('Survey Variables:\nAge p=%.4f, Game Freq p=%.4f, Strategy p=%.4f\n\n', ...
        p_age, p_freq, p_strat);

    %% 분석 3: group(C,1,2,3)별 평균 시간 
    groups = findgroups(allData.group);
    groupMeans = splitapply(@mean, allData.response_time, groups);
    groupAccs = splitapply(@(x) mean(x), allData.error==0, groups);
    groupNames = splitapply(@(x) x(1), allData.group, groups);

    %그룹 요약 테이블 생성 및 저장
    groupSummary = table(groupNames, groupMeans, groupAccs, ...
        'VariableNames', {'Group', 'MeanRT', 'Accuracy'});
    writetable(groupSummary, fullfile(saveFolder, 'group_summary.csv'));

    % 그룹별 반응시간 차이에 대한 ANOVA
    groupLabels = allData.group;
    [p_group_rt, tbl_group_rt, stats_group_rt] = anova1(allData.response_time, groupLabels, 'off');

    % 그룹별 정답률 차이에 대한 ANOVA
    groupLabels = allData.group;
    [p_group_ac, tbl_group_ac, stats_group_ac] = anova1(allData.error==0, groupLabels, 'off');


    fprintf('그룹별 반응시간 차이 (ANOVA):\n');
    fprintf('반응시간 ANOVA p = %.4f\n', p_group_rt);
    fprintf('그룹별 정답률 차이 (ANOVA):\n');
    fprintf('정답률 ANOVA p = %.4f\n', p_group_ac);

    % ANOVA 결과 저장
    anovaTable = cell2table(tbl_group_rt(2:end,:), 'VariableNames', tbl_group_rt(1,:));
    writetable(anovaTable, fullfile(saveFolder, 'anova_group_rt.csv'));
    anovaTable = cell2table(tbl_group_ac(2:end,:), 'VariableNames',tbl_group_ac(1,:));
    writetable(anovaTable, fullfile(saveFolder, 'anova_group_ac.csv'));

    %% 분석결과 시각화 (boxplot 이용)

    % 그룹 내 외 반응시간 & 오답수
    figure;
    subplot(1,2,1)
    boxplot(allData.response_time, allData.within_group, ...
    'Labels', {'Between', 'Within'});
    title('Response Time: Within vs Between');
    ylabel('Response Time (s)');

    subplot(1,2,2)
    boxplot(allData.error, allData.within_group, ...
    'Labels', {'Between', 'Within'});
    title('Error: Within vs Between');
    ylabel('Errors');
    saveas(gcf, fullfile(saveFolder, 'within_vs_between_boxplots.png'));

    %그룹별 반응시간 박스플롯
    figure;
    boxplot(allData.response_time, allData.group);
    title('Response Time by Group');
    ylabel('Response Time (s)');
    saveas(gcf, fullfile(saveFolder, 'response_time_by_group.png'));

    %% 전체 테이블 저장
    writetable(allData, fullfile(saveFolder, 'all_cleaned_data.csv'));
    fprintf('분석 및 저장완료: %s\n', saveFolder);
end
