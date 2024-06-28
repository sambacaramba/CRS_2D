function roughness_length = calculateLineRatios(CRSline, FITline, DETline)
    % This function calculates the ratio of the lengths of two lines CRSline and FITline,
    % considering NaN values appropriately and ensuring no length is added across NaN gaps.

    % Trim NaNs from the start and end of CRSline
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
    trimmedDETline = DETline(firstValidCRS:lastValidCRS); % Trim DETline to the same range as trimmed CRSline
    trimmedDETline(isnan(trimmedCRSline)) = NaN; % Set NaNs in DETline at positions where trimmed CRSline is NaN



    % Calculate lengths ignoring NaNs and handle gaps
    DETlength = calculateLength(trimmedDETline);
    FITlength = calculateLength(trimmedFITline);

    % Calculate the ratio of CRSline to FITline
    roughness_length = DETlength / FITlength;
end

