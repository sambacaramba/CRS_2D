function lengthline = calculateLength(line)

if size(line,2)~=2

% Initialize length
    lengthline = 0;
    
    % Indices of non-NaN values
    nonNaNIndices = find(~isnan(line));

    % Calculate the total length between consecutive non-NaN values only
    for i = 1:length(nonNaNIndices)-1
        currentIdx = nonNaNIndices(i);
        nextIdx = nonNaNIndices(i+1);

        % Only calculate distance to the next index if they are consecutive
        if nextIdx == currentIdx + 1
            verticalDist = line(nextIdx) - line(currentIdx);
            horizontalDist = 1; % consecutive indices have a horizontal distance of 1
            lengthline = lengthline + sqrt(verticalDist^2 + horizontalDist^2);
        end
    end


else 
    % Initialize length
    lengthline = 0;

     % Indices of non-NaN values
    nonNaNIndices = find(~isnan(line(:,2)));

     % Calculate the total length between consecutive non-NaN values only
    for i = 1:length(nonNaNIndices)-1
        currentIdx = nonNaNIndices(i);
        nextIdx = nonNaNIndices(i+1);

        % Only calculate distance to the next index if they are consecutive
        if nextIdx == currentIdx + 1
            verticalDist = line(nextIdx,(1)) - line(currentIdx,(1));
            horizontalDist = line(nextIdx,(2)) - line(currentIdx,(2));
            lengthline = lengthline + sqrt(verticalDist^2 + horizontalDist^2);
        end
    end
end