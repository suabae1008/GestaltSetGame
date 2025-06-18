% 특정 좌표가 삼각형 내부에 존재하는지 판별하는 함수

function inside = isInTriangle(dots, coordinate1, coordinate2, coordinate3)
    
    % 주어진 좌표와 입력된 삼각형 꼭짓점 좌표를 벡터화
    v0 = coordinate3 - coordinate1;
    v1 = coordinate2 - coordinate1;
    v2 = dots - coordinate1;

    % 바리센트릭 좌표계 수식을 위한 벡터 내적값 계산
    dot00 = sum(v0 .* v0, 2);
    dot01 = sum(v0 .* v1, 2);
    dot02 = sum(v0 .* v2, 2);
    dot11 = sum(v1 .* v1, 2);
    dot12 = sum(v1 .* v2, 2);

    % 바리센트릭 좌표계 정규화 상수 설정
    invDenom = 1 ./ (dot00 .* dot11 - dot01 .* dot01);

    % 바리센트릭 좌표계의 u, v 계산
    u = (dot11 .* dot02 - dot01 .* dot12) .* invDenom;
    v = (dot00 .* dot12 - dot01 .* dot02) .* invDenom;

    % 삼각형 내부 조건 판별
    inside = (u >= 0) & (v >= 0) & (u + v <= 1);

    % 결과를 도형 크기에 맞게 재구성
    inside = reshape(inside, 100, 200);
end