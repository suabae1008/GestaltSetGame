function compare_problem7_rt(dataDir)
    if nargin < 1
        dataDir = 'Data'; % 기본 폴더
    end

    files = dir(fullfile(dataDir, '*_results.mat'));
    rt_problem7 = [];
    rt_other = [];

    for i = 1:length(files)
        filePath = fullfile(files(i).folder, files(i).name);
        try
            tmp = load(filePath);
            if ~isfield(tmp, 'results') || ~isfield(tmp.results, 'trials')
                warning("❌ %s: 'results.trials' 필드 없음", files(i).name);
                continue;
            end
            trials = tmp.results.trials;

            for t = 1:length(trials)
                if ~isfield(trials(t), 'original_problem_index') || ~isfield(trials(t), 'response_time')
                    continue;
                end

                rt = trials(t).response_time;
                if isempty(rt) || isnan(rt)
                    continue;
                end

                if trials(t).original_problem_index == 7
                    rt_problem7(end+1) = rt;
                else
                    rt_other(end+1) = rt;
                end
            end

        catch ME
            warning("⚠️ 오류 발생: %s\n%s", files(i).name, ME.message);
        end
    end

    % 결과 출력
    fprintf('\n--- 문제 7 vs 다른 문제들 ---\n');
    fprintf('문제 7 평균 RT: %.3f (n = %d)\n', mean(rt_problem7), length(rt_problem7));
    fprintf('다른 문제 평균 RT: %.3f (n = %d)\n', mean(rt_other), length(rt_other));

    % 통계검정
    [h, p] = ttest2(rt_problem7, rt_other);

    if h
        fprintf('✅ 유의미한 차이 있음 (p = %.4f)\n', p);
    else
        fprintf('❌ 유의미한 차이 없음 (p = %.4f)\n', p);
    end
end
