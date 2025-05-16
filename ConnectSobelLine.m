function output = ConnectSobelLine(input, pixeldist)
    % ConnectSobelLine - Connect endpoints of edges to form a continuous line
    % 
    % input - Binary image of Sobel edge detected image
    % pixeldist - Maximum allowable distance to connect edge endpoints
    % output - Binary image with connected lines
    %

    % Binarize the input image if not already binary
    input = logical(input);
    
    % Skeletonize the edge to ensure one-pixel thickness
    thinnedEdge = bwmorph(input, 'skel', Inf);
    
    % Find endpoints of the thinned edge
    endpoints = bwmorph(thinnedEdge, 'endpoints');
    [endRows, endCols] = find(endpoints);
    
    % Iterate through all pairs of endpoints
    numEndpoints = length(endRows);
    for i = 1:numEndpoints
        for j = i+1:numEndpoints
            % Calculate Euclidean distance between endpoints
            dist = sqrt((endRows(i) - endRows(j))^2 + (endCols(i) - endCols(j))^2);
            
            % If the distance is less than or equal to pixeldist, connect the endpoints
            if dist <= pixeldist
                % Use a simple line drawing algorithm to connect the points
                % Bresenham's line algorithm can be used here
                [rr, cc] = drawLine(endRows(i), endCols(i), endRows(j), endCols(j));
                
                % Set the pixels along the line to 1 (connect the endpoints)
                thinnedEdge(rr, cc) = 1;
            end
        end
    end
    
    % Perform local connection for remaining endpoints
    for distance = 1:3
        % Update endpoints after previous connections
        endpoints = bwmorph(thinnedEdge, 'endpoints');
        [endRows, endCols] = find(endpoints);
        
        % Label connected components
        labeledImage = bwlabel(thinnedEdge, 8);
        
        % Iterate through each endpoint
        numEndpoints = length(endRows);
        for i = 1:numEndpoints
            r = endRows(i);
            c = endCols(i);
            
            % Search for neighboring pixels within the specified distance
            for dr = -distance:distance
                for dc = -distance:distance
                    if dr == 0 && dc == 0
                        continue;
                    end
                    nr = r + dr;
                    nc = c + dc;
                    
                    % Ensure the neighbor is within bounds
                    if nr > 0 && nr <= size(thinnedEdge, 1) && nc > 0 && nc <= size(thinnedEdge, 2)
                        % Check if the neighboring pixel belongs to a different component
                        if thinnedEdge(nr, nc) == 1 && labeledImage(r, c) ~= labeledImage(nr, nc)
                            % Connect the endpoint to the neighboring pixel
                            [rr, cc] = drawLine(r, c, nr, nc);
                            thinnedEdge(rr, cc) = 1;
                        end
                    end
                end
            end
        end
    end
    
    % Output the final connected edge image
    output = thinnedEdge;
end

function [rr, cc] = drawLine(r1, c1, r2, c2)
    % Bresenham's line algorithm to generate pixel coordinates between two points
    % (r1, c1) and (r2, c2)
    
    % Calculate differences
    dr = abs(r2 - r1);
    dc = abs(c2 - c1);
    
    % Determine the direction of increment
    if r1 < r2
        stepR = 1;
    else
        stepR = -1;
    end
    
    if c1 < c2
        stepC = 1;
    else
        stepC = -1;
    end
    
    % Initialize variables
    rr = []; cc = [];
    
    % Bresenham's algorithm
    if dc > dr
        d = 2 * dr - dc;
        r = r1;
        for c = c1:stepC:c2
            rr = [rr; r];
            cc = [cc; c];
            if d > 0
                r = r + stepR;
                d = d - 2 * dc;
            end
            d = d + 2 * dr;
        end
    else
        d = 2 * dc - dr;
        c = c1;
        for r = r1:stepR:r2
            rr = [rr; r];
            cc = [cc; c];
            if d > 0
                c = c + stepC;
                d = d - 2 * dr;
            end
            d = d + 2 * dc;
        end
    end
end
