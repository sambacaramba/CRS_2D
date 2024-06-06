function paintAndAnalyze(img, pixelsize, mov_window_size)
    % Display the image
    fig = figure;
    imshow(img);
    hold on;
    title('Draw ROIs on the image. Press "Done" when finished.');

    % Calculate the length of the moving window in pixels
    mov_window_pixels = round(mov_window_size / pixelsize);

    % Plot the line representing the moving window size
    x_start = 50; % Starting x-coordinate for the line
    y_start = 50; % Starting y-coordinate for the line
    line([x_start, x_start + mov_window_pixels], [y_start, y_start], 'Color', 'k', 'LineWidth', 5);
    text(x_start, y_start + 20, ['Moving window length = ' num2str(mov_window_size) 'µm'], ...
         'Color', 'k', 'FontSize', 12);

    % Initialize the ROI manager
    roiManager = images.roi.Rectangle.empty();
    
    % Button to add ROIs
    uicontrol('Style', 'pushbutton', 'String', 'Add ROI',...
              'Position', [20 20 100 40],...
              'Callback', @addROI);

    % Button to finish and process ROIs
    uicontrol('Style', 'pushbutton', 'String', 'Done',...
              'Position', [140 20 100 40],...
              'Callback', @finishROI);

    % Wait for the user to finish explicitly
    uiwait(fig);

    % Initialize columnPainted
    numCols = size(img, 2);
    columnPainted = zeros(1, numCols);  % Initialization to ensure it's always assigned

    function addROI(~, ~)
        % Interactive ROI addition
        roi = drawrectangle('Label', 'Region of Interest');
        roiManager(end+1) = roi;
 uiwait(fig);
    end


    function finishROI(~, ~)
    % Filter out deleted ROIs before processing
    validROIs = roiManager(isvalid(roiManager));

    % Process ROIs and update columnPainted array
    outputfile = zeros(1, size(img, 2));
    fprintf('Number of ROIs drawn: %d\n', numel(validROIs));

    for i = 1:numel(validROIs)
        try
            bbox = round(validROIs(i).Position);
            xStart = bbox(1);
            xEnd = xStart + bbox(3) - 1;
            outputfile(1, xStart:xEnd) = 1;
            fprintf('ROI %d: from %d to %d\n', i, xStart, xEnd);
        catch ME
            warning('Failed to process ROI %d: %s', i, ME.message);
        end
    end

    pause(1);
    % Save output file which can be loaded in the main script
    save('outputfile.mat', 'outputfile');
    pause(1);
    % Close figure and resume execution
   uiresume(fig);
    close(fig);
    
end
end