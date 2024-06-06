
pixelsize = 0.251 %micrometers per pixel

A = image;
imgray = rgb2gray(A);
B = imcomplement(imgray);


% [h, w, ~] = size(A);
% crop_width = w * 0.12;
% cropped_A = A(:, ceil(crop_width):end-ceil(crop_width));
% 
% [h, ~] = size(cropped_A); % Get the current height of the image
% cropped_A = cropped_A(101:min(h-200, h), :); % Adjust the indices

%Threshold the Image: Apply Otsu's method to threshold the image.
level = graythresh(B);
binary_B = imbinarize(B, level*0.5);




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

% Step 4: Smooth the Detected Line Using a Gaussian Filter

smoothed_line = imgaussfilt(detected_line, 1);

% Visualization
figure, imshow(A), hold on;
plot(1:cols, smoothed_line, 'g', 'LineWidth', 5), hold off;
title('Smoothed Line on Binary Image');

% Step 5: Fit a 3rd Degree Polynomial to the Detected Line

x = 1:cols;
p = polyfit(x, smoothed_line, 5);
fitted_line = polyval(p, x);


% Assume M and N are the dimensions of the original image
M = size(A, 1); % Number of rows
N = size(A, 2); % Number of columns

% Create the figure and perform your plotting
fig = figure;

% Visualization
imshow(A), hold on;
plot(x, fitted_line-30, 'r', 'LineWidth', 1);
plot(1:cols, smoothed_line, 'y', 'LineWidth', 1), hold off;
title('Fitted Polynomial Line on Binary Image');

hold off;

% % Adjust figure and axes properties
% set(fig, 'Units', 'pixels', 'Position', [100, 100, N, M]);
% set(gca, 'Units', 'pixels', 'Position', [0, 0, N, M]);

% Save the figure as an image
filename = 'D:\2D CRS test for histology\output_image2.png'; % Change to your preferred file name
print(fig, filename, '-dpng', ['-r', num2str(200)]); % 96 is the screen resolution in dpi


% Step 6: Loop Through Every Pixel in Both Lines Using an 11x11 Moving Window
 ws= floor(28/pixelsize) %match 28µm window size
window_size = ws;

half_window = floor(window_size / 2);
rows = length(smoothed_line);
cols = length(fitted_line);

% Initialize a matrix to store the differences in surface normals
normal_diff = zeros(rows, 1);

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
fig = figure, plot(normal_diff), title('Difference in Surface Normals');
filename = 'D:\2D CRS test for histology\difference.png'; % Change to your preferred file name
print(fig, filename, '-dpng', ['-r', num2str(200)]); % 96 is the screen resolution in dpi



M = size(A, 1); % Number of rows
N = size(A, 2); % Number of columns

% Create the figure and perform your plotting
fig = figure;
% Display the binary image
 imshow(A), hold on;
plot(x, fitted_line-100, 'g', 'LineWidth', 2);

thresholded_diff = normal_diff; 
thresholded_diff(normal_diff<9) = 0 
thresholded_diff(normal_diff>45) = 45

% Normalize normal_diff to fit within the colormap range
min_angle = 0;
max_angle = 45;
normalized_diff = (normal_diff - min(normal_diff)) / (max(normal_diff) - min(normal_diff));
scaled_diff = normalized_diff * (max_angle - min_angle) + min_angle;

% Get the colormap

load('mycolormap_orientation.mat')
colormaps = mycolormap_orientation;
cmap = colormaps;
num_colors = size(cmap, 1);

% Assign a color to each point on the smoothed_line
color_indices = round(scaled_diff * (num_colors - 1) / max_angle) + 1;
color_indices(color_indices < 1) = 1;
color_indices(color_indices > num_colors) = num_colors;

% Plot the smoothed line with color coding

for i = 1:length(smoothed_line)-1
    % Choose color for the current segment
    color = cmap(color_indices(i), :);

    % Plot the segment
    plot([i i+1], [smoothed_line(i) smoothed_line(i+1)], 'Color', color, 'LineWidth', 5);
end
hold off;

% % Adjust figure and axes properties
% set(fig, 'Units', 'pixels', 'Position', [100, 100, N, M]);
% set(gca, 'Units', 'pixels', 'Position', [0, 0, N, M]);

% Save the figure as an image
filename = 'D:\2D CRS test for histology\CRS_9-45.png'; % Change to your preferred file name
print(fig, filename, '-dpng', ['-r', num2str(200)]); % 96 is the screen resolution in dpi




% colormap(cmap);
% caxis([min_angle max_angle]);
% colorbar;
% title('Smoothed Line with Color Coding');
% hold off;



fig=figure
colormap(cmap);
caxis([0 45]);
colorbar;

% set(fig, 'Units', 'pixels', 'Position', [100, 100, N, M]);


% Save the figure as an image
filename = 'D:\2D CRS test for histology\colorbar.png'; % Change to your preferred file name
print(fig, filename, '-dpng', ['-r', num2str(200)]); % 96 is the screen resolution in dpi





