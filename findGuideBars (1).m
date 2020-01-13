function [guideBarPairs] = findGuideBars(stats)
    
% Get rid of objects which are very unlikely to be guide bars
potentialIdx = [];
for i = 1:length(stats.MajorAxisLength)
    if (stats.Area < 15)
        continue
    end
    
    if (((stats.MajorAxisLength(i) / stats.MinorAxisLength(i)) < 2) ||  ((stats.MajorAxisLength(i) / stats.MinorAxisLength(i)) > 8))
        continue
    end
    
    if (stats.Solidity(i) < 0.75)
        continue
    end
    
   potentialIdx = [potentialIdx, i];
end

guideBarPairs = struct('vBar', {}, 'hBar', {});
potentialBars = stats(potentialIdx,:);
numFound = 0;
for p1 = 1:length(potentialBars.MajorAxisLength)
    for p2 = 1:length(potentialBars.MajorAxisLength)
        
        % Skip if we are comparing the same point
        if (p2 == p1)
            continue
        end
        
        % Approximately 90 Degrees apart
        angleBetween = abs(potentialBars.Orientation(p1) - potentialBars.Orientation(p2));
        if ~(65 < angleBetween  && angleBetween < 115)
            continue
        end
        
        % Length diff must not deviate greater than 40%
        if (abs(potentialBars.MajorAxisLength(p1) - potentialBars.MajorAxisLength(p2))...
                /potentialBars.MajorAxisLength(p1) > 0.40)
            continue
        end
        if (abs(potentialBars.MinorAxisLength(p1) - potentialBars.MinorAxisLength(p2))...
                /potentialBars.MajorAxisLength(p1) > 0.25)
            continue
        end
        
        % Distance comparison
        point1 = potentialBars.Centroid(p1,:);
        point2 = potentialBars.Centroid(p2,:);
        dist = pdist2([point1(1), point1(2)], [point2(1), point2(2)], 'euclidean');
        avgLength = (potentialBars.MajorAxisLength(p1) + potentialBars.MajorAxisLength(p2)) / 2;
        expectedDistance = avgLength * 0.9;
        if ((abs(expectedDistance - dist) / expectedDistance) > 0.30)
            continue
        end
        
        % Confirmed, now store in struct
        if (potentialBars.MajorAxisLength(p1) > potentialBars.MajorAxisLength(p2))
            vBar = table2struct(potentialBars(p1,:));
            hBar = table2struct(potentialBars(p2,:));
        else
            vBar = table2struct(potentialBars(p2,:));
            hBar = table2struct(potentialBars(p1,:));   
        end
        
        % Ineffecient way of handling double counting. MATLAB structs suck
        duptest = struct('vBar', vBar, 'hBar', hBar);
        dup = false;
        if (~isempty(guideBarPairs))
            for i = 1:numFound
                if (isequal(duptest, guideBarPairs(i)))
                    dup = true;
                end
            end
        end
        
        if (~dup)
            guideBarPairs(numFound+1).vBar = vBar;
            guideBarPairs(numFound+1).hBar = hBar;  
            numFound = numFound + 1;
        end
    end
end
    
end