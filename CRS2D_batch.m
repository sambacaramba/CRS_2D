
function [normal_diff, fitted_line, smoothed_line, largestObjectLabel] = CRS2D_batch(savepath, fname, image, pixelsize, mov_window_size,angle_range,chosenThreshold,artefactmask,exclusion_threshold)




A = image;

if ndims(A) == 3 && size(A, 3) == 3
        % Convert the RGB image to grayscale
        A = rgb2gray(A);
    
    end
imgray = (A);
 B = imcomplement(imgray);
% B = imgray;

% [chosenThreshold] = choose_threshold(B);
binary_B = imbinarize(B, chosenThreshold);

binary_B2 = imfill(binary_B,'holes');
% Identify connected components
connComp = bwconncomp(binary_B2);

% Measure properties of connected components
objectMeasurements = regionprops(connComp, 'area');

% Extract areas into a simple array
allAreas = [objectMeasurements.Area];

% Identify the largest object
[~, indexOfLargest] = max(allAreas);

% Create a binary image with only the largest object
largestObjectLabel = labelmatrix(connComp) == indexOfLargest;

% Display the result
imshow(largestObjectLabel);

% Detect the First Non-Black Pixel: Find the first non-black pixel from the top of the image and save its height coordinate.

[rows, cols] = size(largestObjectLabel);
detected_line = zeros(1, cols);
for col = 1:cols
    for row = 1:rows
        if largestObjectLabel(row, col) ~= 0
            detected_line(col) = row;
            break;
        end
    end
end

% Visualization


figure, imshow(A), hold on;
plot(1:cols, detected_line, 'r', 'LineWidth', 5), hold off;
title('Detected Line on Binary Image');



%  if isfile('outputfile.mat')
%         delete('outputfile.mat');
%     end
% %if there are artefacts, user can opt to mask them out. 
% userResponse = promptYesNo()
% if userResponse
%     close all 
% paintAndAnalyze(image, pixelsize, mov_window_size);
% else 
% end
% pause(1)


% Step 4: Smooth the Detected Line Using a Gaussian Filter


endpoint=rows-5;
endpoint2 = 5

detected_line(detected_line==0) = NaN;
detected_line(detected_line>endpoint) = NaN; 
detected_line(detected_line<endpoint2) = NaN; 
detected_line(1:3) = NaN;
detected_line(cols-3:cols)= NaN;

smoothed_line = imgaussfilt(detected_line, 1);

% Visualization
figure, imshow(image), hold on;
plot(1:cols, smoothed_line, 'g', 'LineWidth', 5), hold off;
title('Smoothed Line on Binary Image');

% Step 5: Fit a 3rd Degree Polynomial to the Detected Line
%% iterative fit 
%% Iterative fit
smoothed_line_iter = smoothed_line; % Assuming smoothed_line is defined elsewhere
ws = floor(exclusion_threshold / pixelsize); % 10µm difference in fit is set as big deviation -->excluded
cols = length(smoothed_line_iter); %  number of columns
x = 1:cols; % x-coordinates for fitting
% figure;
m = 1; % Iteration counter
stoprule = inf; % Initialize stoprule with a value that guarantees loop entry

while stoprule > ws
    % Perform polynomial fitting excluding NaNs
    validIndices = ~isnan(smoothed_line_iter);
    p = polyfit(x(validIndices), smoothed_line_iter(validIndices), 5);
    fitted_line = polyval(p, x);
    
    % Calculate the absolute difference only for valid indices
    diff = abs(smoothed_line_iter - fitted_line);
    diff(~validIndices) = NaN; % Preserve NaNs in the difference calculation
    
    % Identify badly fit areas and update stoprule
    badFitIndices = diff > ws;
    stoprule = sum(badFitIndices(:)); % Count of points where the fit is considered bad
    
    % Update smoothed_line_iter for the next iteration
    smoothed_line_iter(badFitIndices) = NaN;
    
    % Plotting the evolution of stoprule
    kuvaaja(m, 1) = stoprule;
%     plot(kuvaaja);
%     drawnow;
    
    m = m + 1; % Update iteration counter
end

%%
% Assume M and N are the dimensions of the original image
M = size(A, 1); % Number of rows
N = size(A, 2); % Number of columns

% Create the figure and perform your plotting
fig = figure('Visible','off');

% Visualization
imshow(image), hold on;
plot(x, fitted_line-30, 'r', 'LineWidth', 1);
plot(1:cols, smoothed_line, 'y', 'LineWidth', 1);

plot(1:cols, smoothed_line_iter-100, 'g', 'LineWidth', 1), hold off;
legend('fitted line','detected line','used for fit')
title('Fitted Polynomial Line on Binary Image');
hold off;

% % Adjust figure and axes properties
% set(fig, 'Units', 'pixels', 'Position', [100, 100, N, M]);
% set(gca, 'Units', 'pixels', 'Position', [0, 0, N, M]);

% Save the figure as an image
filename = [savepath '\' fname '_lines.png']; % Change to your preferred file name
print(fig, filename, '-dpng', ['-r', num2str(96)]); % 96 is the screen resolution in dpi


% Step 6: Loop Through Every Pixel in Both Lines Using an 11x11 Moving Window
 ws= floor(mov_window_size/pixelsize) %match chosen moving window size
window_size = ws;

half_window = floor(window_size / 2);
rows = length(smoothed_line);
cols = length(fitted_line);

% Initialize a matrix to store the differences in surface normals
normal_diff = NaN(rows, 1);

for col = 1 + half_window : cols - half_window
    % Extract data for the current window
    window_indices = col-half_window : col+half_window;
    window_smoothed = smoothed_line(window_indices);
    window_fitted = fitted_line(window_indices);

    % Fit a 1st-degree polynomial (linear fit) to both lines
    p_smoothed = polyfit(window_indices, window_smoothed, 1);
    p_fitted = polyfit(window_indices, window_fitted, 1);

    % Calculate surface normals for each line
    normal_smoothed = [-p_smoothed(1), 1]; % For y = mx + b, normal is (-m, 1)
    normal_fitted = [-p_fitted(1), 1];

    % Normalize the normals
    normal_smoothed = normal_smoothed / norm(normal_smoothed);
    normal_fitted = normal_fitted / norm(normal_fitted);

    % Calculate the difference between normals
    normal_diff(col) = rad2deg(acos(dot(normal_smoothed, normal_fitted)));
end

% Visualization (Optional)
% Here you can visualize the normal_diff array to see the differences in normals
% fig = figure, plot(normal_diff), title('Difference in Surface Normals');
% filename = [savepath '\' fname '_difference.png']; % Change to your preferred file name
% print(fig, filename, '-dpng', ['-r', num2str(200)]); % 96 is the screen resolution in dpi



M = size(A, 1); % Number of rows
N = size(A, 2); % Number of columns

% Create the figure
fig = figure('Visible','off');


ax = gca; % Get the handle to the current axes
% ax.YDir = 'reverse'; % Optionally ensure Y direction is correct if needed
ax.YTick = linspace(0, M, 10); % Define 10 tick positions from the top to bottom of the image
ax.YTickLabel = linspace(0, 90, 10); % Set labels from 0 to 90


imshow(image), hold on; % Display the binary image
plot(x, fitted_line-100, 'g', 'LineWidth', 2); % Plotting the original line

% % Threshold the normal_diff values
% thresholded_diff = normal_diff; 
% thresholded_diff(normal_diff < angle_range(1)) = 0; % Values below 9 set to 0
% thresholded_diff(normal_diff > angle_range(2)) = angle_range(2); % Values above 45 set to 45
% 
% % Load your custom colormap
% load('mycolormap_orientation.mat');
% cmap = mycolormap_orientation;
% num_colors = size(cmap, 1);
% 
% 
% min_angle = angle_range(1);
% max_angle = angle_range(2);
% % Calculate color indices directly based on thresholded_diff
% color_indices = round((thresholded_diff - min_angle) / (max_angle - min_angle) * (num_colors - 1)) + 1;
% color_indices(color_indices < 1) = 1;
% color_indices(color_indices > num_colors) = num_colors;
% color_indices(isnan(color_indices)) = 1;
% % Plot the smoothed line with color coding
% for i = 1:length(smoothed_line)-1
%     color = cmap(color_indices(i), :); % Choose color for the current segment
%     plot([i i+1], [smoothed_line(i) smoothed_line(i+1)], 'Color', color, 'LineWidth', 1);
% end
% 
% % Adjust figure and axes properties if needed
% % set(fig, 'Units', 'pixels', 'Position', [100, 100, N, M]);
% % set(gca, 'Units', 'pixels', 'Position', [0, 0, N, M]);
% 
% 
% 
%  colormap(cmap);
%  caxis([min_angle max_angle]);
%  colorbar;
%  







% Image dimensions
width = N; % Width of the image
height = M; % Height of the image

% Values for the line
y_values = normal_diff; % 
y_values(y_values==0) = NaN;
x_values = 1:width; % X values from 1 to the width of the image

% Scaling Y values to fit in the lowest fourth of the image
% Compute the vertical offset and scaling factor
% lower_bound = floor(3 * height / 4);
% upper_bound = height;
 scale_factor = -(M) / 90;

% Scale and shift y_values
y_positions = abs((y_values * scale_factor)+M);

% Plotting the line
h_line = plot(x_values, y_positions, 'k-', 'LineWidth', 2); % black line

ax = gca;
set(ax, 'Visible', 'on'); % Make sure axes are visible
ax.YTick = linspace(1, height, 10); % Place 10 ticks along the width

labelarray = linspace(90, 0, 10);
labelarray_with_degrees = arrayfun(@(x) [num2str(x) '°'], labelarray, 'UniformOutput', false);
ax.YTickLabel = labelarray_with_degrees; % Labels from 90 to 0

% Setting up axes



% Labels (optional)
xlabel('X position');
ylabel('Value range 0 to 90');

% Hold off to finish plotting

 % Calculate the length of the moving window in pixels
    mov_window_pixels = round(mov_window_size / pixelsize);

    % Plot the line representing the moving window size
    x_start = 50; % Starting x-coordinate for the line
    y_start = 50; % Starting y-coordinate for the line
    line([x_start, x_start + mov_window_pixels], [y_start, y_start], 'Color', 'k', 'LineWidth', 5);
    text(x_start, y_start + 20, ['Moving window length = ' num2str(mov_window_size) 'µm'], ...
         'Color', 'k', 'FontSize', 12);


%show where masks of artefacts were applied if they exist


if exist('artefactmask', 'var') && ~isempty(artefactmask)
    % Only run this block if artefactmask was passed and is not empty
   
    % Initialize a handle for the legend
    h = [];

    % Loop through the outputfile to identify regions with ones
    for col = 1:N
        if artefactmask(col) == 1
            % Create a box that spans the full height of the image at this column
            xBox = [col col col+1 col+1];  % x coordinates of the box
            yBox = [1 M M 1];  % y coordinates from bottom to top of y axis
            h = [h, fill(xBox, yBox, 'm', 'FaceAlpha', 0.2, 'EdgeColor', 'none')];
        end
    end

    % Add a legend if there are any overlays
    if ~isempty(h)
        legend(h(1), 'Excluded from analysis', 'Location', 'best');
    end

end

 fname_tit = strrep(fname,'_',' ')
 titleStr = sprintf('Result image: %s | moving window length: %dµm  | pixel size: %.4f µm/pixel', ...
                   fname_tit, mov_window_size, pixelsize);
 title(titleStr);


% Save the figure as an image
angleRangeString = sprintf('_CRS_%d-%d', angle_range(1), angle_range(2));

filename = fullfile(savepath, [fname angleRangeString '.png']); % Using fullfile for better path handling
print(fig, filename, '-dpng', ['-r', '96']); % Specifying DPI






