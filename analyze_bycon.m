function analyze_bycon(dataFolder)

    files = dir(fullfile(dataFolder, '*_results.mat'));
    
    allData = table(); % 누적 테이블
    
    for i = 1:length(files)
        filename = files(i).name;
        filepath = fullfile(dataFolder, filename);

        try
            data = load(filepath);
            results = data.results;

            if ~isfield(results, 'trials') || ~isfield(results, 'responses')
                warning("❌ %s: results.trials 또는 results.responses 없음", filename);
                continue;
            end
            
            if isfield(results.responses, 'group')
                grp_raw = results.responses.group;
                if ischar(grp_raw)
                    group_str = string(grp_raw);
                elseif iscell(grp_raw)
                    group_str = string(grp_raw{1});
                elseif isstring(grp_raw)
                    group_str = grp_raw(1);
                else
                    warning("❌ %s: results.responses.group 형식 이상", filename);
                    continue;
                end
            else
                warning("❌ %s: results.responses.group 필드 없음", filename);
                continue;
            end

            % trials 구조를 테이블로 변환
            trials = struct2table(results.trials);

            % group, subject_id 컬럼 추가
            trials.group = repmat(group_str, height(trials), 1);
            trials.subject_id = repmat(string(results.participant_id), height(trials), 1);

            % 누적 테이블에 합치기
            allData = [allData; trials];

        catch ME
            warning("⚠️ %s 처리 중 오류: %s", filename, ME.message);
        end
    end

    % 분석 조건 정의 (original_problem_index와 비교 그룹)
    % 조건 1: 문제 1,2,5,6 → control vs group1
    % 조건 2: 문제 3,4 → control vs group2
    % 조건 3: 문제 5,6 → control vs group3
    conditions = {
        struct('indices', [1 2 5 6], 'group', "1")
        struct('indices', [3 4],     'group', "2")
        struct('indices', [5 6],     'group', "3")
    };

    for i = 1:length(conditions)
        cond = conditions{i};

        % control 그룹
        subset_ctrl = allData(ismember(allData.original_problem_index, cond.indices) & allData.group == "C", :);
        % 실험 그룹
        subset_exp  = allData(ismember(allData.original_problem_index, cond.indices) & allData.group == cond.group, :);

        rt_ctrl = subset_ctrl.response_time;
        rt_exp  = subset_exp.response_time;

        fprintf("\n--- 조건 %d: group %s vs control ---\n", i, cond.group);
        fprintf("control 평균 RT: %.3f (n = %d)\n", mean(rt_ctrl), numel(rt_ctrl));
        fprintf("group %s 평균 RT: %.3f (n = %d)\n", cond.group, mean(rt_exp), numel(rt_exp));

        % t-검정 수행
        [h, p] = ttest2(rt_ctrl, rt_exp);
        if h
            fprintf("(p = %.4f)\n", p);
        else
            fprintf("(p = %.4f)\n", p);
        end
    end
end
