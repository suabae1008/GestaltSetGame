function analyze_WIgroup_eff(folderName)
    files = dir(fullfile(folderName, '*.mat'));
    allRT = [];
    allWG = [];

    for i = 1:length(files)
        filePath = fullfile(folderName, files(i).name);
        fileData = load(filePath);

        vars = fieldnames(fileData);
        data = [];

        for v = 1:length(vars)
            currentVar = fileData.(vars{v});
            if isstruct(currentVar) && isfield(currentVar, 'trials') && isfield(currentVar, 'responses')
                data = currentVar;
                break;
            end
        end

        if isempty(data)
            warning('파일 %s 에서 유효한 데이터 구조를 찾을 수 없습니다. 건너뜁니다.', files(i).name);
            continue;
        end

        trials = struct2table(data.trials);

        if ~ismember('response_time', trials.Properties.VariableNames) || ...
           ~ismember('within_group', trials.Properties.VariableNames)
            warning('파일 %s 에 필요한 필드가 없습니다. 건너뜁니다.', files(i).name);
            continue;
        end

        validIdx = ~isnan(trials.response_time) & trials.original_problem_index ~= -1 & trials.original_problem_index ~= -2;
        rt = trials.response_time(validIdx);
        wg = trials.within_group(validIdx);

        allRT = [allRT; rt];
        allWG = [allWG; wg];
    end

    % 빈 데이터 예외 처리
    %if isempty(allRT)
    %    error('반응 시간 데이터가 없습니다. 분석할 수 없습니다.');
    %end

    % 그룹 구분
    rt_within = allRT(allWG == 1);
    rt_between = allRT(allWG == 0);

    % 평균 출력
    fprintf('평균 반응시간 (그룹 내): %.3f 초\n', mean(rt_within));
    fprintf('평균 반응시간 (그룹 외): %.3f 초\n', mean(rt_between));

    % 정규성 검정
    [~, p_norm1] = kstest((rt_within - mean(rt_within))/std(rt_within));
    [~, p_norm2] = kstest((rt_between - mean(rt_between))/std(rt_between));

    if p_norm1 > 0.05 && p_norm2 > 0.05
        [~, pval] = ttest2(rt_within, rt_between);
        testUsed = 't-test';
    else
        pval = ranksum(rt_within, rt_between);
        testUsed = 'Wilcoxon rank-sum';
    end

    fprintf('통계검정: %s, p = %.4f\n', testUsed, pval);

    % 시각화
    figure;
    boxplot([rt_within; rt_between], [ones(size(rt_within)); zeros(size(rt_between))]);
    set(gca, 'XTickLabel', {'Within Group', 'Between Group'});
    ylabel('Response Time (s)');
    title('반응시간 비교 (1 vs 0)');
    grid on;

    % 저장
    saveas(gcf, fullfile(folderName, 'within_group_response_time.png'));
    fprintf('✅ 분석 및 시각화 완료. 결과 이미지 저장됨.\n');
end
