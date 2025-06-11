function analyzeAllResults(dataFolder)
    files = dir(fullfile(dataFolder, '*_results.mat'));
    allResults = [];

    % 모든 파일 로딩
    for i = 1:length(files)
        data = load(fullfile(dataFolder, files(i).name));
        if isfield(data, 'results')
            allResults = [allResults, data.results];
        end
    end

    % 분석 수행
    stats = computeAllStats(allResults);

    % 결과 저장
    save('GroupAnalysis.mat', 'stats');
end
