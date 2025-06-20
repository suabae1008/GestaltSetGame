function analyze_bycon(dataFolder) 

    files = dir(fullfile(dataFolder, '*_results.mat')); % _results.mat으로 끝나는 파일 모두 불러오기
    allData = table();
    
    for i = 1:length(files) % 파일 갯수만큼 반복
        filename = files(i).name;
        filepath = fullfile(dataFolder, filename); % i번째 파일 불러오기

        try
            data = load(filepath);
            results = data.results; % 파일 열고 실험 결과 불러오기
            
            grp = results.responses.group; % results.responses.group의 값을 string으로 변환
            if ischar(grp)
                group_str = string(grp);
            elseif iscell(grp)
                group_str = string(grp{1});
            elseif isstring(grp)
                group_str = grp(1);
            end

            trials = struct2table(results.trials);

            % group, subject_id 열 추가
            trials.group = repmat(group_str, height(trials), 1);
            trials.subject_id = repmat(string(results.participant_id), height(trials), 1);

            allData = [allData; trials];

        catch ME % file에 오류가 있는 경우
            warning("️ %s 처리 중 오류: %s", filename, ME.message);
        end
    end

    % 1. 문제 1,2,5,6 비교 in control vs group1
    % 2. 문제 3,4 비교 in control vs group2
    % 3. 문제 5,6 비교 in control vs group3
    conditions = {
        struct('indices', [1 2 5 6], 'group', "1")
        struct('indices', [3 4],     'group', "2")
        struct('indices', [5 6],     'group', "3")
    };

    for i = 1:length(conditions)
        cond = conditions{i};

        % control 그룹
        ctrl_grp = allData(ismember(allData.original_problem_index, cond.indices) & allData.group == "C", :); % group이 C인 행 추출
        % 실험 그룹
        exp_grp  = allData(ismember(allData.original_problem_index, cond.indices) & allData.group == cond.group, :); % group이 1,2,3인 행 추출

        % control, 실험 그룹 반응시간 추출
        rt_ctrl = ctrl_grp.response_time;
        rt_exp  = exp_grp.response_time;

        fprintf("\n----- group %s vs control -----\n", cond.group);
        fprintf("control 평균 RT: %.3f (n = %d)\n", mean(rt_ctrl), numel(rt_ctrl));
        fprintf("group %s 평균 RT: %.3f (n = %d)\n", cond.group, mean(rt_exp), numel(rt_exp));

        % t-검정 수행
        [h, p] = ttest2(rt_ctrl, rt_exp);
        fprintf("(p = %.4f)\n", p);
    end
end
