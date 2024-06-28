function output= complexRoughness(CRSline, FITline, optimalpath)

 validIndicesCRS = find(~isnan(CRSline)); % Find indices of non-NaN values in CRSline
    if isempty(validIndicesCRS)
        error('CRSline contains only NaN values');
    end
    firstValidCRS = validIndicesCRS(1); % Index of the first non-NaN value
    lastValidCRS = validIndicesCRS(end); % Index of the last non-NaN value

    trimmedCRSline = CRSline(firstValidCRS:lastValidCRS); % Trimmed CRSline

    % Apply the NaN pattern from the trimmed CRSline to FITline
    trimmedFITline = FITline(firstValidCRS:lastValidCRS); % Trim FITline to the same range as trimmed CRSline
    trimmedFITline(isnan(trimmedCRSline)) = NaN; % Set NaNs in FITline at positions where trimmed CRSline is NaN

    %Apply NaN pattern to the optimal path detected in a* algorithm


    nanIndicesCRS = find(isnan(CRSline));

% Loop over these indices to check values in optimalpath(:, 2)
for i = 1:length(nanIndicesCRS)
    % Find rows in optimalpath where the second column matches the NaN index in CRSline
    rowsToNaN = optimalpath(:, 2) == nanIndicesCRS(i);
    
    % Set these rows in optimalpath to NaN
    optimalpath(rowsToNaN, :) = NaN;
end

       FITlength = calculateLength(trimmedFITline);
          complexlength = calculateLength(optimalpath);

              output = complexlength / FITlength;