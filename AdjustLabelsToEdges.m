function [leftEdge, rightEdge] = AdjustLabelsToEdges(labeledImage)
    % AdjustLabelsToEdges - Adjust labels to ensure they touch both left and right edges
    %
    % labeledImage - Input labeled image
    % leftEdge - Coordinates of the left edge for matching labels
    % rightEdge - Coordinates of the right edge for matching labels
    %

    % Extract the leftmost and rightmost columns
    leftColumn = labeledImage(:, 1);
    rightColumn = labeledImage(:, end);

    % Find unique labels in the leftmost and rightmost columns
    leftLabels = unique(leftColumn);
    rightLabels = unique(rightColumn);

    % Remove the background label (assumed to be 0)
    leftLabels(leftLabels == 0) = [];
    rightLabels(rightLabels == 0) = [];

    % Find matching labels between left and right columns
    matchingLabels = intersect(leftLabels, rightLabels);

    % If no matching labels are found, output an error message
    if isempty(matchingLabels)
        disp('Edges were not found or do not belong to the same label.');
        leftEdge = [];
        rightEdge = [];
        return;
    end

    % Get the first matching label
    label = matchingLabels(1);
    
    % Find the leftmost and rightmost coordinates for the current label
    [rows, cols] = find(labeledImage == label);
    
    % Find the coordinate on the left edge
    leftEdgeIndex = find(cols == 1, 1);
    leftEdge = [rows(leftEdgeIndex), cols(leftEdgeIndex)];
    
    % Find the coordinate on the right edge
    rightEdgeIndex = find(cols == size(labeledImage, 2), 1);
    rightEdge = [rows(rightEdgeIndex), cols(rightEdgeIndex)];
end
