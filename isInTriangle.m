function inside = isInTriangle(dots, coordinate1, coordinate2, coordinate3)
    v0 = coordinate3 - coordinate1;
    v1 = coordinate2 - coordinate1;
    v2 = dots - coordinate1;
    dot00 = sum(v0 .* v0, 2);
    dot01 = sum(v0 .* v1, 2);
    dot02 = sum(v0 .* v2, 2);
    dot11 = sum(v1 .* v1, 2);
    dot12 = sum(v1 .* v2, 2);
    invDenom = 1 ./ (dot00 .* dot11 - dot01 .* dot01);
    u = (dot11 .* dot02 - dot01 .* dot12) .* invDenom;
    v = (dot00 .* dot12 - dot01 .* dot02) .* invDenom;
    inside = (u >= 0) & (v >= 0) & (u + v <= 1);
    inside = reshape(inside, 100, 200);
end