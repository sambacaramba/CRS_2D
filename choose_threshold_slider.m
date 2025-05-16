function result = choose_threshold_slider(grayImage, binFactor, pixelSize, mov_window_size)
    fprintf('--- Threshold Slider Tool with Optional ROI ---\n');

    if nargin < 2, binFactor = 0; end
    if binFactor ~= 0
        if ~ismember(binFactor, 2:8)
            error('binFactor must be 0 or an integer between 2 and 8.');
        end
        grayImage = imresize(grayImage, 1/binFactor, 'bilinear');
    end

    originalImageSize = size(grayImage);
    grayImage_uint8 = im2uint8(grayImage);
    grayImage = im2double(grayImage_uint8);

    levelOtsu = graythresh(grayImage_uint8);

    fig = figure('Name', 'Threshold Tool', ...
                 'WindowState', 'maximized', ...
                 'KeyPressFcn', @keyHandler, ...
                 'CloseRequestFcn', @closeHandler);

    ax1 = subplot(1, 6, 1:5, 'Parent', fig);
    imshow(grayImage, 'Parent', ax1);
    hold on;
    binImage = imbinarize(grayImage, levelOtsu);
    overlayHandle = imshow(binImage, 'Parent', ax1);
    set(overlayHandle, 'AlphaData', 0.3 * binImage);
    title(ax1, sprintf('Threshold = %.2f (Otsu)', levelOtsu));

    ax2 = subplot(1, 6, 6, 'Parent', fig);
    [counts, bins] = imhist(grayImage_uint8);
    bar(ax2, bins, counts, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none');
    ylim(ax2, [0 max(counts)*1.1]);
    thresholdLine = line(ax2, [levelOtsu*255, levelOtsu*255], ylim(ax2), ...
                         'Color', 'r', 'LineWidth', 2);
    title(ax2, 'Histogram');

    data.currentThreshold = levelOtsu;
    data.chosenThreshold = [];
    data.doMasking = false;
    guidata(fig, data);

    labelText = uicontrol('Style', 'text', ...
                          'String', sprintf('Threshold: %.2f', levelOtsu), ...
                          'Units', 'normalized', ...
                          'Position', [0.90 0.80 0.08 0.05], ...
                          'FontSize', 12);

    uicontrol('Style', 'text', 'String', 'Threshold Value', ...
              'Units', 'normalized', ...
              'Position', [0.90 0.85 0.08 0.05]);

    uicontrol('Style', 'checkbox', 'String', 'Add artefact mask after threshold', ...
              'Units', 'normalized', 'Position', [0.65 0.05 0.25 0.05], ...
              'Value', false, 'Callback', @(src,~) setMaskFlag(src));

    slider = uicontrol('Style', 'slider', ...
              'Min', 0.05, 'Max', 0.95, ...
              'Value', levelOtsu, ...
              'SliderStep', [0.01, 0.1], ...
              'Units', 'normalized', ...
              'Position', [0.92 0.1 0.03 0.7], ...
              'Callback', @sliderChanged);

    uicontrol('Style', 'pushbutton', 'String', 'Finalize', ...
              'Units', 'normalized', ...
              'Position', [0.90 0.05 0.08 0.05], ...
              'Callback', @finalizeAndClose);

    uiwait(fig);
    if isvalid(fig)
        data = guidata(fig);
        result.chosenThreshold = data.chosenThreshold;
        close(fig);
    end

    if data.doMasking
        paintAndAnalyze(im2uint8(grayImage), pixelSize, mov_window_size,binFactor);
        % Assumes paintAndAnalyze saves 'outputfile.mat'
        if isfile('outputfile.mat')
            s = load('outputfile.mat');
            result.outputfile = s.outputfile;
        else
            warning('outputfile.mat not found after masking.');
            result.outputfile = [];
        end
    else
        result.outputfile = [];
    end

    function sliderChanged(src, ~)
        tVal = get(src, 'Value');
        binImage = imbinarize(grayImage, tVal);
        set(overlayHandle, 'CData', binImage);
        set(overlayHandle, 'AlphaData', 0.3 * binImage);
        set(thresholdLine, 'XData', [tVal*255, tVal*255]);
        set(labelText, 'String', sprintf('Threshold: %.2f', tVal));
        title(ax1, sprintf('Threshold = %.2f', tVal));
        data = guidata(fig);
        data.currentThreshold = tVal;
        guidata(fig, data);
    end

    function keyHandler(~, event)
        if strcmp(event.Key, 'f')
            finalizeAndClose();
        end
    end

    function setMaskFlag(src)
        data = guidata(fig);
        data.doMasking = logical(get(src, 'Value'));
        guidata(fig, data);
    end

    function finalizeAndClose(~, ~)
        data = guidata(fig);
        data.chosenThreshold = data.currentThreshold;
        guidata(fig, data);
        uiresume(fig);
    end

    function closeHandler(~, ~)
        uiresume(fig);
        delete(fig);
    end
end
