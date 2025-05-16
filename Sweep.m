function output = Sweep(volume)
    % Check if the input is a logical volume
    if ~islogical(volume)
        error('Input must be a logical volume.');
    end

    % Label connected components in the volume
    
    
[xs, ys, zs] = size(volume);
if zs==1 
    CC = bwconncomp(volume,8);
else 
CC = bwconncomp(volume, 26);  % 26-connectivity for 3D volumes
end 

    % Measure the size of each connected component
    stats = regionprops(CC, 'Area');

    % Find the largest component based on area
    [~, largestIdx] = max([stats.Area]);

    % Create an output volume that contains only the largest object
    output = false(size(volume));  % Initialize output as a logical volume
    output(CC.PixelIdxList{largestIdx}) = true;  % Set the largest object to true
end