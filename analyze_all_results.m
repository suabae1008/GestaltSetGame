function analyze_all_results(folderPath)
    % 모든 .mat 파일을 읽고 trials + responses 정보 병합하여 분석 수행
    files = dir(fullfile(folderPath, '*.mat'));
    allData = [];

    % 결과 저장 폴더
    saveFolder = fullfile(folderPath, 'analysis_results');
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end

    for i = 1:length(files)
        fileData = load(fullfile(folderPath, files(i).name));
        varNames = fieldnames(fileData);
        data = fileData.(varNames{1});

        % 유효한 results 구조인지 검사
        if ~isfield(data, 'trials') || ~isfield(data, 'responses')
            warning('Invalid results structure in file: %s', files(i).name);
            continue;
        end

        % trials: struct 배열 → table
        trials = struct2table(data.trials);
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

        allData = [allData; trials];
    end

    % 이상치 제거용 IQR 기반 함수 정의
    isOutlier = @(x) x < (quantile(x,0.25) - 1.5*iqr(x)) | x > (quantile(x,0.75) + 1.5*iqr(x));
    allData.outlier = isOutlier(allData.response_time);

    % 저장용 통계 테이블 초기화
    summaryStats = table;

    %% 분석 1: 그룹 내 vs 외 반응시간 및 정확도 비교
    within = allData(allData.within_group==1, :);
    between = allData(allData.within_group==0, :);

    [~, p_rt] = ttest2(within.response_time, between.response_time);
    [~, p_acc] = ttest2(1 - within.error, 1 - between.error);

    fprintf('Group Within vs Between:\n');
    fprintf('Response Time p = %.4f\nAccuracy p = %.4f\n', p_rt, p_acc);

    %% 분석 2: 설문 변수별 반응 시간 차이 (age, frequency, strategy)
    g1 = findgroups(allData.age);
    g2 = findgroups(allData.game_frequency);
    g3 = findgroups(allData.strategy);

    [p_age, tbl_age, ~] = anova1(allData.response_time, g1, 'off');
    [p_freq, tbl_freq, ~] = anova1(allData.response_time, g2, 'off');
    [p_strat, tbl_strat, ~] = anova1(allData.response_time, g3, 'off');

    fprintf('Survey Variables:\nAge p=%.4f, Game Freq p=%.4f, Strategy p=%.4f\n', ...
        p_age, p_freq, p_strat);

    %% 분석 3: group(C,1,2,3)별 평균 시간 
    groups = findgroups(allData.group);
    groupMeans = splitapply(@mean, allData.response_time, groups);
    groupAccs = splitapply(@(x) mean(1 - x), allData.error, groups);
    groupNames = splitapply(@(x) x(1), allData.group, groups);

    groupSummary = table(groupNames, groupMeans, groupAccs, ...
        'VariableNames', {'Group', 'MeanRT', 'Accuracy'});
    writetable(groupSummary, fullfile(saveFolder, 'group_summary.csv'));

    % 그룹별 반응시간 차이에 대한 일원분산분석 (ANOVA)
    groupLabels = allData.group;  % 그룹 라벨 (예: 'C', '1', '2', '3')
    [p_group_rt, tbl_group_rt, stats_group_rt] = anova1(allData.response_time, groupLabels, 'off');

    % 결과 출력
    fprintf('그룹별 반응시간 차이 (ANOVA):\n');
    fprintf(' - 반응시간 ANOVA p = %.4f\n', p_group_rt);

    % 결과 저장
    anovaTable = cell2table(tbl_group_rt(2:end,:), 'VariableNames', tbl_group_rt(1,:));
    writetable(anovaTable, fullfile(saveFolder, 'anova_group_rt.csv'));

    %% 전체 테이블 저장
    writetable(allData, fullfile(saveFolder, 'all_cleaned_data.csv'));

    % 시각화 예시: 그룹별 반응시간 박스플롯
    figure;
    boxplot(allData.response_time, allData.group);
    title('Response Time by Group');
    ylabel('Response Time (s)');
    saveas(gcf, fullfile(saveFolder, 'response_time_by_group.png'));

    fprintf('✅ 분석 완료: %s\n', saveFolder);
end
