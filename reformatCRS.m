function CRSnew = reformatCRS(midindex, CRS)
    % Validate the input sizes
    if length(midindex) ~= length(CRS)
        error('midindex and CRS must be the same length.');
    end
    
    % Determine the size of CRSnew
    numGroups = max(midindex);
     % Calculate the number of trailing NaNs
    lastValidIndex = find(~isnan(midindex), 1, 'last');
    numTrailingNaNs = length(midindex) - lastValidIndex;
    numGroups = max(midindex)+numTrailingNaNs;
    numColumns = 0;
    
    % Find the maximum number of occurrences for any index in midindex
    for i = 1:numGroups
        numOccurrences = sum(midindex == i);
        if numOccurrences > numColumns
            numColumns = numOccurrences;
        end
    end
    
    % Initialize CRSnew with NaNs to handle empty entries
    CRSnew = NaN(numGroups, numColumns);
    
    % Array to keep track of the current fill position for each row
    currentPosition = zeros(numGroups, 1);
    
    % Loop through each element in midindex to place values in CRSnew
    for i = 1:length(midindex)
        group = midindex(i);
        if ~isnan(group)
        pos = currentPosition(group) + 1;  % Get the next position to fill
        CRSnew(group, pos) = CRS(i);  % Place the CRS value
        currentPosition(group) = pos;  % Update the position
        end
    end
end