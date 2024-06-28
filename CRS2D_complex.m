function CRScomplex_occurences = CRS2D_complex(fitted_line,optimalpath,savepath, fname, image, pixelsize, mov_window_size,angle_range,imagesave)
%interpolate the optimal path to have exactly one spaced horizontal coordinates and interpolated vertical coordinates to be able to loop throug the line
%the shortcut here is that as the lines are curved each pixel jump is still
%regarded as a length of one although diagonal direction can be sqrt(2)
data = optimalpath;

dataX = data(:,2);
dataY = data(:,1);

datanew = NaN(5*length(dataX),2);

k=1
for i=1:length(dataX)-1

    change = abs(dataX(i)-dataX(i+1));
    
    if change > 1
        
        p1 = [dataX(i), dataY(i)];  % Point (x1, y1)
        p2 = [dataX(i+1), dataY(i+1)];  % Point (x2, y2)

        % Calculate slope (m)
        m = (p2(2) - p1(2)) / (p2(1) - p1(1));

        % Calculate intercept (b)
        b = p1(2) - m * p1(1);

        % Define the range of x coordinates from the first to the second point
        xCoordinates = p1(1):1:p2(1);

        % Calculate y coordinates using the line equation
        yCoordinates = m * xCoordinates + b;

        % Combine x and y coordinates into a matrix
        linePoints = [yCoordinates; xCoordinates]';
        ktmp = length(linePoints);
        datanew(k:k+ktmp-1,1)=linePoints(:,1);
        datanew(k:k+ktmp-1,2)=linePoints(:,2);

        k= k+ktmp-1;

    else 
        datanew(k,1)=dataY(i);
        datanew(k,2)=dataX(i);
        k=k+1;
    end
end

cutter = min(find(isnan(datanew(:,2))))-1;
datanew = datanew(1:cutter,1:2);


% Step 6: Loop Through Every Pixel in Both Lines Using an 11x11 Moving Window
 ws= floor(mov_window_size/pixelsize) %match chosen moving window size
window_size = ws;

half_window = floor(window_size / 2);
rows = length(datanew);
cols = length(fitted_line);

% Initialize a matrix to store the differences in surface normals
normal_diff = NaN(rows, 1);
middleindexarray = NaN(rows,1);
for col = 1 + window_size : rows - window_size
    % Extract data for the current window
    window_indices = col-half_window : col+half_window;
    window_complex = datanew(window_indices,:);

    %get matching position from fitted window using the center value of the
    %complex surface
    midindex = ceil(length(window_complex) / 2);
    middleindex = window_complex(midindex,2);
if ~isnan(middleindex)&&middleindex>window_size&&middleindex<rows-window_size
    window_fitted = fitted_line(middleindex-half_window:middleindex+half_window);
    fitted_indices = (middleindex-half_window:middleindex+half_window);

    % Fit a 1st-degree polynomial (linear fit) to both lines
    p_complex = polyfit(window_complex(:,2), window_complex(:,1), 1);
    p_fitted = polyfit(fitted_indices, window_fitted, 1);

    % Calculate surface normals for each line
    normal_complex = [-p_complex(1), 1]; % For y = mx + b, normal is (-m, 1)
    normal_fitted = [-p_fitted(1), 1];

    % Normalize the normals
    normal_complex = normal_complex / norm(normal_complex);
    normal_fitted = normal_fitted / norm(normal_fitted);

    % Calculate the difference between normals
    angle = acos(dot(normal_complex, normal_fitted)); % Result in radians
    angle_deg = rad2deg(angle); % Convert angle to degrees

    % Adjust angles over 90 degrees to their acute counterparts
    if angle_deg > 90
    angle_deg = abs(angle_deg - 180);
    end

    normal_diff(col) = angle_deg;

    %save middleindex to a variable 
    middleindexarray(col,:) = middleindex;
 
end

end

CRScomplex_occurences = reformatCRS(middleindexarray, normal_diff);
CRScomplex_occurences= sum(CRScomplex_occurences,2,'omitnan');
CRScomplex_occurences(CRScomplex_occurences==0) = NaN; 
CRScomplex_occurences(CRScomplex_occurences>90) = 90;
A=image;

M = size(A, 1); % Number of rows
N = size(A, 2); % Number of columns

% Create the figure
fig = figure('Visible','off');


ax = gca; % Get the handle to the current axes
% ax.YDir = 'reverse'; % Optionally ensure Y direction is correct if needed
ax.YTick = linspace(0, M, 10); % Define 10 tick positions from the top to bottom of the image
ax.YTickLabel = linspace(0, 120, 10); % Set labels from 0 to 90


imshow(A), hold on; % Display the binary image
plot(1:length(fitted_line), fitted_line-100, 'g', 'LineWidth', 2); % Plotting the original line

% Threshold the normal_diff values
thresholded_diff = normal_diff; 
thresholded_diff(normal_diff < angle_range(1)) = 0; % Values below 9 set to 0
thresholded_diff(normal_diff > angle_range(2)) = angle_range(2); % Values above 45 set to 45

% Load your custom colormap
load('mycolormap_orientation.mat');
cmap = mycolormap_orientation;
num_colors = size(cmap, 1);


min_angle = angle_range(1);
max_angle = angle_range(2);
% Calculate color indices directly based on thresholded_diff
color_indices = round((thresholded_diff - min_angle) / (max_angle - min_angle) * (num_colors - 1)) + 1;
color_indices(color_indices < 1) = 1;
color_indices(color_indices > num_colors) = num_colors;
color_indices(isnan(color_indices)) = 1;
% Plot the smoothed line with color coding
for i = 1:length(datanew)-1
    color = cmap(color_indices(i), :); % Choose color for the current segment
    plot([datanew(i,2) datanew(i+1,2)], [datanew(i,1) datanew(i+1,1)], 'Color', color, 'LineWidth', 5);
end

% Adjust figure and axes properties if needed
% set(fig, 'Units', 'pixels', 'Position', [100, 100, N, M]);
% set(gca, 'Units', 'pixels', 'Position', [0, 0, N, M]);



 colormap(cmap);
 caxis([min_angle max_angle]);
 colorbar;


fname_tit = strrep(fname,'_',' ')
 titleStr = sprintf('Result image: %s\nmoving window length: %dµm   pixel size: %.4f µm/pixel', ...
                   fname_tit, mov_window_size, pixelsize);
 title(titleStr);





% Image dimensions
width = N; % Width of the image
height = M; % Height of the image

% Values for the line
y_values = CRScomplex_occurences; % 
y_values(y_values==0) = NaN;
x_values = 1:width; % X values from 1 to the width of the image

% Scaling Y values to fit in the lowest fourth of the image
% Compute the vertical offset and scaling factor
% lower_bound = floor(3 * height / 4);
% upper_bound = height;
 scale_factor = -(M) / 90;

% Scale and shift y_values
y_positions = abs((y_values * scale_factor)+M);

% Plotting the line (make sure they match)
sx = length(x_values);
sy = length(y_positions);
if sx ~= sy
    diffsysx = sy-sx;
    if diffsysx>0
        y_positions = y_positions(1:end-abs(diffsysx),1);
    else  
            y_positions(end:end+abs(diffsysx),1) = NaN;
       
    end
end

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

 if isfile('outputfile.mat')
       load('outputfile.mat');


    % Initialize a handle for the legend
    h = [];

    % Loop through the outputfile to identify regions with ones
    for col = 1:N
        if outputfile(col) == 1
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




% Save the figure as an image
angleRangeString = sprintf('_CRS_%d-%d', angle_range(1), angle_range(2));

filename = fullfile(savepath, [fname angleRangeString '_complex' '.png']); % Using fullfile for better path handling
print(fig, filename, '-dpng', ['-r', '400']); % Specifying DPI

close(fig);