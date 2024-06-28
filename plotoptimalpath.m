function plotoptimalpath(inputimage, OP, name,pixel_size, spacing, savepath)

fig = figure('Visible','off')
imagesc(~inputimage)

    colormap(flipud(gray));

hold on
plot(OP(1,2),OP(1,1),'o','color','y','LineWidth',10)
plot(OP(end,2),OP(end,1),'o','color','b','LineWidth',10)
plot(OP(:,2),OP(:,1),'r')
legend('Goal','Start','Path','Location', 'best')
title(name)
axis equal tight



% Calculate the number of pixels in each dimension
[imageHeight, imageWidth, ~] = size(inputimage);

% Calculate the number of ticks based on the pixel size and desired spacing
xTicks = 0:spacing/pixel_size:imageWidth; % Positions where x-ticks will be placed
yTicks = 0:spacing/pixel_size:imageHeight; % Positions where y-ticks will be placed

% Set tick labels in micrometers
xLabels = 0:spacing:max(xTicks)*pixel_size;
yLabels = flip(0:spacing:max(yTicks)*pixel_size); % Flip y labels for correct orientation

% Adjust axes properties
ax = gca;
ax.XTick = xTicks;
ax.YTick = yTicks;
ax.XTickLabel = arrayfun(@num2str, xLabels, 'UniformOutput', false);
ax.YTickLabel = arrayfun(@num2str, yLabels, 'UniformOutput', false);

% Label axes
xlabel('(\mum)');
ylabel('(\mum)');

% Optional: Set grid for better visualization
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridColor = [0.1, 0.1, 0.1]; % Light gray grid lines

filename = fullfile(savepath, [name '_optimalpath' '.png']); % Using fullfile for better path handling
print(fig, filename, '-dpng', ['-r', '200']); % Specifying DPI
close(fig);
