function stats = computeAllStats(allResults)
    responseTimes = [];
    errors = [];
    withinGroup = [];
    age = [];
    group = {};
    frequency = {};
    strategy = {};
    
    for i = 1:length(allResults)
        res = allResults(i);
        rt = [res.trials.response_time];
        err = [res.trials.error];
        wg = [res.trials.within_group];
        
        responseTimes = [responseTimes, rt];
        errors = [errors, err];
        withinGroup = [withinGroup, wg];
        age = [age, repmat(res.responses.age, 1, length(rt))];
        group = [group, repmat({res.responses.group}, 1, length(rt))];
        frequency = [frequency, repmat({res.responses.game_frequency}, 1, length(rt))];
        strategy = [strategy, repmat({res.responses.strategy}, 1, length(rt))];
    end

    % 기술통계
    stats.global.rt_mean = mean(responseTimes);
    stats.global.rt_median = median(responseTimes);
    stats.global.rt_std = std(responseTimes);
    stats.global.accuracy = 1 - mean(errors);

    % 그룹 내 vs 외
    stats.within.mean_rt = mean(responseTimes(withinGroup == 1));
    stats.outside.mean_rt = mean(responseTimes(withinGroup == 0));
    stats.within.accuracy = 1 - mean(errors(withinGroup == 1));
    stats.outside.accuracy = 1 - mean(errors(withinGroup == 0));
end
