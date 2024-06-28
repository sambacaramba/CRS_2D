clear all 
close all 
%settings for user

 pixel_size = 0.2515; %pixel size in µm 
 mov_window_size = 28; %moving window size in µm
 angle_range =[0, 90]; %show angles from 
% pixel_size = 2*0.233; %pi
%% choose what folder to analyze and load data (single sample or batch) 
folders = uipickfiles('FilterSpec','D:\','Output','struct')
 
%create a savefolder for all the results. Results will be saved to
%"Batch_Results" in the first parent folder of chosen folders. 
savepath = [folders(1).folder '\Batch_Results'] %savefolder
    A = exist(savepath);
    if A == 0
    mkdir(savepath);
    else 
    end  
for i =15:numel(folders)

    fname = folders(i).name;
    start = max(strfind(fname,'\'));
    endd = max(strfind(fname,'.'));
    fname = fname(start+1:endd-1);

    image = imread(folders(i).name);
[CRS, chosenThreshold, fitline, Detectedline, Mask]= CRS2D(savepath, fname, image, pixel_size,mov_window_size,angle_range);

 if isfile('outputfile.mat')
       load('outputfile.mat');

       artefactmask = logical(outputfile); 
       CRS(artefactmask) = NaN;
 end

%add complex "roughness" here and also CRS for the complex surface. 
load("NeighboorsTable2.mat")
[outputImage, leftEdge, rightEdge] = processMaskForASTARpath(Mask);
[OptimalPath,OpenedMAT]=ASTARPATH2SIDED(leftEdge(2),leftEdge(1),~outputImage,rightEdge(2),rightEdge(1),4,NeighboorsTable{4});

nametmp = strrep(fname,'_',' ');
spacing = 300;
plotoptimalpath(outputImage, OptimalPath, nametmp,pixel_size,spacing,savepath);

%CRS for complex surface
imagesave = true;

[CRScomplex] = CRS2D_complex(fitline,OptimalPath,savepath, fname, image, pixel_size, mov_window_size,angle_range,imagesave);

 if isfile('outputfile.mat')
       load('outputfile.mat');

       artefactmask = logical(outputfile); 
       CRScomplex(artefactmask) = NaN;
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


save([savepath '\tempres'], 'CRSres')

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

save([savepath '\fullres'], 'CRSres')

T = struct2table(CRSres);
T.CRSline = [];
T.FITline = [];
T.DETline = [];
T.Mask = [];
T.optimalPath = [];
T.CRScomplex = [];
writetable(T, [savepath '\Results.xlsx']);
