% 정답의 시각적 군집 내 존재여부 확인하는 함수

function ingroup = isingroup(group, probIDX)
    
    % 정보를 저장할 0 행렬 설정
    ingroup = zeros(1, 10);
    
    % 각 실험군마다 특정 문제가 나오면 그 순서의 ingroup 값을 1로 바꿈
    switch group
        case '1'
            for i = 1:length(probIDX)
                if probIDX(i) == 1 || probIDX(i) == 2 || probIDX(i) == 5 || probIDX(i) == 6
                    ingroup(i) = 1;
                end
            end
        case '2'
            for i = 1:length(probIDX)
                if probIDX(i) == 3 || probIDX(i) == 4
                    ingroup(i) = 1;
                end
            end
        case '3'
            for i = 1:length(probIDX)
                if probIDX(i) == 5 || probIDX(i) == 6
                    ingroup(i) = 1;
                end
            end
    end
end