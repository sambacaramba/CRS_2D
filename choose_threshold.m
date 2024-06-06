function [chosenThreshold] = choose_threshold(grayImage)

% Step 1: Binarize with Otsu's method to find the initial threshold
level = graythresh(grayImage); % Otsu's method
otsuBinarizedImage = imbinarize(grayImage, level);

figure 
imshow(grayImage);
% Visualize the Otsu's method result
figure;

% Step 2: Visualize with 20 different thresholds
for i = 1:10
    thresholdMultiplier = 0.2 * i;
    customThreshold = level * thresholdMultiplier;
    binarizedImage = imbinarize(grayImage, customThreshold);
    
    subplot(5, 2, i);
    imshow(binarizedImage);
    title(['Threshold x' num2str(thresholdMultiplier)]);
end

% Step 3: Prompt the user to choose a threshold
prompt = 'Enter the threshold multiplier (e.g., 1.2 for Threshold x1.2): ';
thresholdMultiplierChosen = input(prompt);

% Validate the input
while isempty(thresholdMultiplierChosen) || thresholdMultiplierChosen < 0.1 || thresholdMultiplierChosen > 2
    disp('Invalid input. Please choose a multiplier between 0.1 and 2.');
    thresholdMultiplierChosen = input(prompt);
end

% Step 4: Use the chosen number for thresholding
chosenThreshold = level * thresholdMultiplierChosen;
finalBinarizedImage = imbinarize(grayImage, chosenThreshold);

% Display the chosen threshold result
figure;
imshow(finalBinarizedImage);
title(['Final Binarization with Threshold x' num2str(thresholdMultiplierChosen)]);