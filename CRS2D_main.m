%% CRS2D Main Batch Analysis Script


% This script performs 2D surface roughness analysis on cartilage images.
% It runs both standard and complex CRS2D analyses across multiple images,
% using user-provided thresholds and artefact masks. Run
% SetThresholdsAndArtefactmasks.m prior to running this script and use the
% outputfile in this script
% 
% Results are saved as figures,
% MAT files, and Excel summaries.
%
%option to save a closeup imagesequence of the analysis --> set imagesave
%variable as true. If you want to do this, only analyze one or two samples
%at a time as it is very slow to generate over thousands of images. 

clear all 
close all 

%settings for user
 pixel_size = 0.221; %pixel size in µm 
 mov_window_size = 28; %moving window size in µm
 angle_range =[0, 90]; %show angles from 

%% choose samples to analyze (single sample or batch) 
folders = uipickfiles('FilterSpec','D:\','Output','struct','Prompt','Choose samples for analysis')

%% Load Thresholds and artefact masks (the file is created in SetThresholdsAndArtefactmasks.m)
threspath = uipickfiles('FilterSpec','D:\*.mat','Output','struct','Prompt','Choose Threshold file')
 ThreshArts = load(threspath.name);
 ThresRes = ThreshArts.ThresRes;


 
% Preallocate based on the number of elements in ThresRes
numSamples = length(ThresRes);

% Preallocate a cell array for filenames (since sample is a character array)
filenames = cell(1, numSamples);

% Preallocate a numeric array for thresholds
thresholds = zeros(1, numSamples);

% Fill the arrays
for i = 1:numSamples
    filenames{1, i} = ThresRes(i).sample;
    thresholds(1, i) = ThresRes(i).Threshold;
end


%create a savefolder for all the results. Results will be saved to
%"Batch_Results" in the first parent folder of chosen folders. 
savepath = [folders(1).folder ['\Batch_Results_' num2str(mov_window_size)]] %savefolder
    A = exist(savepath);
    if A == 0
    mkdir(savepath);
    else 
    end  



for i =1:numel(folders)

    fname = folders(i).name;
    start = max(strfind(fname,'\'));
    endd = max(strfind(fname,'.'));
    fname = fname(start+1:endd-1);

    % Find match index (k)
    k = find(strcmp(fname, filenames));
    if isempty(k)
        disp(['Skipping unmatched file: ' fname]);
        continue;
    end

    image = imread(folders(i).name);

    if isfield(ThresRes(k), 'artefactMask') && ~isempty(ThresRes(k).artefactMask)
        artefactmask = logical(ThresRes(k).artefactMask);
    else 
        artefactmask = [];
    end


    [CRS, fitline, Detectedline, Mask] = CRS2D_batch(savepath, fname, image, pixel_size, mov_window_size, angle_range, thresholds(1,k),artefactmask);

    % Use artefactMask from ThresRes(k)
    if isfield(ThresRes(k), 'artefactMask') && ~isempty(ThresRes(k).artefactMask)
        artefactmask = logical(ThresRes(k).artefactMask);

        % Ensure artefactmask length matches CRS
        len_diff = length(CRS) - length(artefactmask);
        if len_diff > 0
            artefactmask = [false(1, floor(len_diff/2)), artefactmask, false(1, ceil(len_diff/2))];
        elseif len_diff < 0
            artefactmask = artefactmask(1:length(CRS));
        end

        CRS(artefactmask) = NaN;
    end

    % Complex surface path
    load("NeighboorsTable2.mat")
    [outputImage, leftEdge, rightEdge] = processMaskForASTARpath(Mask);
    [OptimalPath, OpenedMAT] = ASTARPATH2SIDED(leftEdge(2), leftEdge(1), ~outputImage, rightEdge(2), rightEdge(1), 4, NeighboorsTable{4});

    nametmp = strrep(fname, '_', ' ');
    spacing = 300;
    plotoptimalpath(outputImage, OptimalPath, nametmp, pixel_size, spacing, savepath);

    imagesave = false;
    [CRScomplex] = CRS2D_complex(fitline, OptimalPath, savepath, fname, image, pixel_size, mov_window_size, angle_range, imagesave,artefactmask);

    % Apply artefactmask to CRScomplex
    if exist('artefactmask', 'var') && ~isempty(artefactmask)
        if length(CRScomplex) ~= length(artefactmask)
            len_diff = length(CRScomplex) - length(artefactmask);
            if len_diff > 0
                artefactmask = [false(1, floor(len_diff/2)), artefactmask, false(1, ceil(len_diff/2))];
            elseif len_diff < 0
                artefactmask = artefactmask(1:length(CRScomplex));
            end
        end
        CRScomplex(artefactmask) = NaN;
        clear artefactmask
    end

    CRSres(i).sample = fname;
    CRSres(i).CRSline = CRS;
    CRSres(i).FITline = fitline;
    CRSres(i).DETline = Detectedline;
    CRSres(i).Mask = Mask;
    CRSres(i).optimalPath = OptimalPath;
    CRSres(i).CRScomplex = CRScomplex;

    close all
end

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
save(fullfile(savepath, sprintf('tempres_%dum_%s.mat', mov_window_size, timestamp)), 'CRSres');

for i= 1: length(CRSres)
tmp = (CRSres(i).CRSline);
CRSres(i).meanORI = nanmean(tmp)
CRSres(i).stdORI = nanstd(tmp)
CRSres(i).roughness_length = calculateLineRatios(CRSres(i).CRSline, CRSres(i).FITline, CRSres(i).DETline);
CRSres(i).roughness_complex = complexRoughness(CRSres(i).CRSline, CRSres(i).FITline, CRSres(i).optimalPath);
tmplength = tmp; 
tmplength(~isnan(tmp)) = 1;
tmplength = nansum(tmplength)


tmp05 = tmp(tmp>5);
tmp10 = tmp(tmp>10);
tmp15 = tmp(tmp>15);
tmp20 = tmp(tmp>20);
tmp25 = tmp(tmp>25);
tmp30 = tmp(tmp>30);


CRSres(i).over05deg_percent = (length(tmp05)/tmplength)*100;
CRSres(i).over10deg_percent = (length(tmp10)/tmplength)*100;
CRSres(i).over15deg_percent = (length(tmp15)/tmplength)*100;
CRSres(i).over20deg_percent = (length(tmp20)/tmplength)*100;
CRSres(i).over25deg_percent = (length(tmp25)/tmplength)*100;
CRSres(i).over30deg_percent = (length(tmp30)/tmplength)*100;

tmp = CRSres(i).CRScomplex;
CRSres(i).ComplexMeanCRS = nanmean(tmp)
CRSres(i).ComplexStdCRS = nanstd(tmp)

tmplength = tmp; 
tmplength(~isnan(tmp)) = 1;
tmplength = nansum(tmplength)

tmp05 = tmp(tmp>5);
tmp10 = tmp(tmp>10);
tmp15 = tmp(tmp>15);
tmp20 = tmp(tmp>20);
tmp25 = tmp(tmp>25);
tmp30 = tmp(tmp>30);


CRSres(i).Complexover05deg_percent = (length(tmp05)/tmplength)*100;
CRSres(i).Complexover10deg_percent = (length(tmp10)/tmplength)*100;
CRSres(i).Complexover15deg_percent = (length(tmp15)/tmplength)*100;
CRSres(i).Complexover20deg_percent = (length(tmp20)/tmplength)*100;
CRSres(i).Complexover25deg_percent = (length(tmp25)/tmplength)*100;
CRSres(i).Complexover30deg_percent = (length(tmp30)/tmplength)*100;

end

save(fullfile(savepath, sprintf('fullres_%dum_%s.mat', mov_window_size, timestamp)), 'CRSres');


if isscalar(CRSres)
    T = struct2table(CRSres, 'AsArray', true);
else
    T = struct2table(CRSres);
end

T.CRSline = [];
T.FITline = [];
T.DETline = [];
T.Mask = [];
T.optimalPath = [];
T.CRScomplex = [];



writetable(T, fullfile(savepath, sprintf('Results_%dum_%s.xlsx', mov_window_size, timestamp)));


