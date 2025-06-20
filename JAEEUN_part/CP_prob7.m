function CP_prob7(dataDir)

    files = dir(fullfile(dataDir, '*_results.mat')); % _results.mat으로 끝나는 파일 모두 불러오기
    rt_problem7 = [];
    rt_other = [];

    for i = 1:length(files) % 파일 갯수만큼 반복
        filePath = fullfile(files(i).folder, files(i).name);
        try
            tmp = load(filePath); % 파일 읽기
            trials = tmp.results.trials;

            for t = 1:length(trials)
                rt = trials(t).response_time; % 반응 시간
                prob_idx = trials(t).original_problem_index; % trial의 문제 번호

                if trials(t).original_problem_index == 7 % 문제 번호가 7인 경우와 아닌 경우로 나누
                    rt_problem7(end+1) = rt;
                elseif prob_idx ~= -1 && prob_idx ~= -2
                    rt_other(end+1) = rt;
                end
            end

        catch ME % file에 오류가 있는 경우
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
