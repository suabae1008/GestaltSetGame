function ingroup = isingroup(group, probIDX)

    ingroup = zeros(1, 10);
    
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