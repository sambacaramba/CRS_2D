%Save Thresholds for CRS2D analysis. 

%The tool uses otsu as a starting guess for thresholding. Histological
%stains can be very different even within the same sample set. This tool
%allows the user to set the correct thresholding value quickly for each
%sample. Just choose the value, wehere the surface of the sample is clearly
%defined and press finalize. 

%Sometimes virtual histological samples have preparation or image processing artefacts like folded
%tissue, uneven cutting or failed stitching. If you see any of these, check
%the box for masking artefacts and another image will open where you will
%draw a rectangle over the artefact. Columns within the rectangle are
%omitted in the final analysis. 

%set pixel size and moving window size for CRS2D analysis

clear all 
close all 
%settings for user

 pixel_size = 0.221; %pixel size in µm 
 mov_window_size = 28; %moving window size in µm

%% choose what folder to analyze and load data (single sample or batch) 
folders = uipickfiles('FilterSpec','D:\','Output','struct')
 
%create a savefolder for all the results. Results will be saved to
%"Batch_Results" in the first parent folder of chosen folders. 
savepath = [folders(1).folder '\Thresholds'] %savefolder
    A = exist(savepath);
    if A == 0
    mkdir(savepath);
    else 
    end  

thresholds = zeros(1,numel(folders))    
for i =1:numel(folders)

 if isfile('outputfile.mat')
        delete('outputfile.mat');
    end


    image = imread(folders(i).name);
    imgray = rgb2gray(image);
    B = imcomplement(imgray);
 [tempres] = choose_threshold_slider(B,4,pixel_size,mov_window_size); % bin=4, 0.7um/pixel, 200um window 
thresholds(1,i) = tempres.chosenThreshold;

 if isfile('outputfile.mat')
       load('outputfile.mat');
 else 
     outputfile = [];
 end


fname = folders(i).name;
    start = max(strfind(fname,'\'));
    endd = max(strfind(fname,'.'));
    fname = fname(start+1:endd-1);

ThresRes(i).sample = fname;
ThresRes(i).Threshold = tempres.chosenThreshold;
ThresRes(i).artefactMask = outputfile;
close all 
end

savenamethres = fullfile(savepath,'ThresRes.mat')
save(savenamethres,'ThresRes')