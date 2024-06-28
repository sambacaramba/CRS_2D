function [outputImage, leftEdge, rightEdge] = processMaskForASTARpath(inputMask)
    % Ensure the input is a binary mask
    inputMask = logical(inputMask);
    
    % Step 1: Edge detection
    edges = edge(inputMask, 'Sobel');
    
    % Step 2: Dilate the edges to ensure a minimum width of 3 pixels
    edges = bwmorph(edges, 'dilate', 1);  % Dilate edges to increase width
    
    % Step 3: Find first pixel from left and right
    [rows, cols] = find(edges);
    
    % Finding the first pixel touching the left and right edges within the mask
    leftmostCol = min(cols);
    rightmostCol = max(cols);
    leftEdge = [rows(cols == leftmostCol), leftmostCol * ones(sum(cols == leftmostCol), 1)];
    rightEdge = [rows(cols == rightmostCol), rightmostCol * ones(sum(cols == rightmostCol), 1)];
    
    % Find first touching pixels based on vertical coordinates
    leftEdge = leftEdge(1, :);
    rightEdge = rightEdge(1, :);
    
    % Step 4: Remove components not connecting the identified pixels
    labeledImage = bwlabel(edges);
    leftLabel = labeledImage(leftEdge(1), leftEdge(2));
    rightLabel = labeledImage(rightEdge(1), rightEdge(2));
    
    % Ensure the left and right edges are part of the same connected component
    if leftLabel ~= rightLabel
        outputImage = false(size(inputMask));
        warning('Left and right edge pixels are not connected!');
        return;
    end
    
    % Keep only the component that includes the left and right edges
    outputImage = labeledImage == leftLabel;
    
    % Optional: Connect the left and right edges with a line (if needed)
%     outputImage = bwmorph(outputImage, 'thin', inf);  % Thin to single-pixel width
%     outputImage = bwmorph(outputImage, 'spur', inf);  % Remove spurs if necessary
    
    % Optional: Return only the line connecting the edges
    % This line could be obtained using additional image processing steps or using a custom line drawing algorithm
end