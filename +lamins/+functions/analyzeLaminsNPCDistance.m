function [ D, rD ] = analyzeLaminsNPCDistance( MD, lamin_z_position, npc_z_position, lamin_channel, npc_channel )
%analyzeLaminsNPCDistance Analyze distance between lamin meshwork
%     laminNPCAnalysis - Analyze Lamin Fibers and Nuclear Pore Complexes
%     Copyright (C) 2020 Mark Kittisopikul, Northwestern University
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.

if(nargin < 1 || isempty(MD))
    MD = MovieData.load;
elseif(ischar(MD))
    MD = MovieData.load(MD);
end

outputDir = 'analyzeLaminsNPCDistance_2018_05_09';

oldOutputDirs = {'../analyzeLaminsNPCDistance'};

cd(MD.movieDataPath_);
mkdir(outputDir);
cd(outputDir);

if(nargin < 3)
    
    dirsToCheck = [outputDir oldOutputDirs];
    parameterFileExists = false;
    for d=1:length(dirsToCheck)
        currentDir = dirsToCheck{d};
        parameterFile = fullfile(currentDir,'z_parameters.mat');
        parameterFileExists = exist(parameterFile,'file');
        if(parameterFileExists)
            break;
        end
    end
    
    if(parameterFileExists)
        disp('Loading parameter file:');
        disp(parameterFile);
        load(parameterFile);
        lamin_z_position
        npc_z_position
        if(exist('lamin_channel','var'))
            lamin_channel
            npc_channel
        end
        if(exist('cropRect','var'))
            cropRect
        end
    else
        if(~isempty(regexp(MD.channels_(1).name_,'SIM561','once')) || ~isempty(regexp(MD.channels_(1).name_,'SIM488','once')))
            lamin_channel = 2;
            npc_channel = 1;
        else
            lamin_channel = 1;
            npc_channel = 2;
        end
        [~,~,Zindices] = autofocus(MD,[MD.imSize_/2-64 128 128],'WAVS');
        Zindices(cellfun('isempty',Zindices)) = { round(MD.zSize_/2) };
        Zindices = cellfun(@min,Zindices);
        hmv = movieViewer(MD);
%         defaultLaminPos = round(MD.zSize_/2);
%         defaultNPCPos = defaultLaminPos-2;
        defaultLaminPos = Zindices(1);
        defaultNPCPos = Zindices(2);
        
        h_edit_depth=  findtag(hmv,'edit_depth');
        h_edit_depth.String = num2str(defaultLaminPos);
        h_edit_depth.Callback(h_edit_depth,[]);
        
        zpos = inputdlg({'Lamin Z Position','NPC Z Position','Lamin channel','NPC channel'}, ...
            'Enter Z Positions for Lamins and NPCS', ...
            1, ...
            {num2str(defaultLaminPos),num2str(defaultNPCPos),num2str(lamin_channel),num2str(npc_channel)}, ...
            struct('WindowStyle','normal'));
        lamin_z_position = str2double(zpos{1});
        npc_z_position = str2double(zpos{2});
        lamin_channel = str2double(zpos{3});
        npc_channel = str2double(zpos{4});
        close(hmv);
    end
end

if(~exist('lamin_channel','var'))
    lamin_channel = 1;
end
if(~exist('npc_channel','var'))
    npc_channel = 2;
end



slash_location = strfind(MD.movieDataPath_,filesep);
md_title = MD.movieDataPath_(slash_location(end-1):end);

% Lamin image
I = MD.channels_(lamin_channel).loadImage(1,lamin_z_position);
I_npc = MD.channels_(npc_channel).loadImage(1,npc_z_position);

if(size(I,1) > 1024)
    if(~exist('cropRect','var'))
        hfigcrop = figure;
        imshowpair(I,I_npc);
        I_sz = size(I);
        I_center = ceil(I_sz/2);
        hrect = imrect(hfigcrop.Children(1),[I_center-[512 512] 1023 1023]);
        setResizable(hrect,false);
        cropRect = wait(hrect);
        close(hfigcrop);
    end
    I = imcrop(I,cropRect);
    I_npc = imcrop(I_npc,cropRect);
else
    cropRect = [1 1 size(I)];
end



save('z_parameters.mat','lamin_z_position','npc_z_position','lamin_channel','npc_channel','cropRect');


gcp

F = OrientationSpaceRidgeFilter(1./2/pi./2,[],8,'none');
R = I*F;
R3 = R.getResponseAtOrderFT(3,2);

import lamins.functions.*;
import lamins.classes.*;

% Get NLMS
original.maxima = R.getRidgeOrientationLocalMaxima;
[nlms,nlms_offset] = nonLocalMaximaSuppressionPrecise(R3.a,original.maxima);

% Get Lamin Threshold
nlms_nz = nlms(nlms ~= 0 & ~isnan(nlms));
% Perhaps detect when there are too many inliers
[~,inliers] = detectOutliers(nlms_nz);
if(length(inliers)./length(nlms_nz) > 0.85)
    T = thresholdOtsu(nlms_nz(inliers));
else
    T = thresholdOtsu(nlms_nz(:));
end
% T = 0;
nlms_offset(nlms < T) = NaN;

nlms_mip = nanmax(nlms,[],3);
hfig = figure;
imshow(nlms_mip,[]);
title(md_title, 'interpreter', 'none');
saveas(hfig,'Lamin_nlms_mip.fig');
saveas(hfig,'Lamin_nlms_mip.png');

% Get Mask
% M = imfill(nlms_mip > T,'holes');
% figure; imshow(M,[]);
% M = imopen(M,strel('disk',5));
% cc = bwconncomp(M);
% [~,idx] = max(cellfun('prodofsize',cc.PixelIdxList));
% mask = labelmatrix(cc) == idx;
% figure; imshowpair(I,mask);
maskFile = [pwd filesep 'mask.png'];
if(exist(maskFile,'file'))
    mask = imread(maskFile);
    mask = logical(mask);
else
    mask = maskFromSteerable(R3);
end
hfig = figure;
imshowpair(I,mask);
title(md_title, 'interpreter', 'none');
saveas(hfig,'Nucleus_mask.fig');
saveas(hfig,'Nucleus_mask.png');

% Apply mask to NLMS
nlms_offset(~repmat(mask,[1 1 size(nlms_offset,3)])) = NaN;

[X,Y] = meshgrid(1:size(nlms,2),1:size(nlms,1));

% Get sub-pixel NLMS points
XX = joinColumns(X+cos(original.maxima).*nlms_offset);
YY = joinColumns(Y+sin(original.maxima).*nlms_offset);

% Find sub-pixel NLMS angles
s = ~isnan(XX);
A2 = squeeze(interp3(R.a,repmat(XX(s),1,1,17),repmat(YY(s),1,1,17),ones(size(YY(s))).*shiftdim(1:17,-1)));
[maxima2] = interpft_extrema(A2,2);
[~,minidx] = min(min(abs(maxima2 - original.maxima(s)*2),2*pi-abs(maxima2 - original.maxima(s)*2)),[],2);
minind = sub2ind(size(maxima2),(1:length(minidx)).',minidx);
MM = maxima2(minind)/2;

% Extrapolate additional points from sub-pixels points to decrease
% discretization artifact
LL = [XX(s) YY(s);
      XX(s)+0.5*cos(MM+pi/2) YY(s)+0.5*sin(MM+pi/2); XX(s)-0.5*cos(MM+pi/2) YY(s)-0.5*sin(MM+pi/2);
      XX(s)+0.25*cos(MM+pi/2) YY(s)+0.25*sin(MM+pi/2); XX(s)-0.25*cos(MM+pi/2) YY(s)-0.25*sin(MM+pi/2)];

% Find NPCs
% psd = pointSourceDetection(I_npc,2,'mask',mask);
psd = pointSourceDetection(I_npc,2);
[~,psd.inliers] = detectOutliers(psd.A);
if(length(psd.inliers)./length(psd.A) > 0.8)
    psd.T = thresholdRosin(psd.A(psd.inliers));
else
    psd.T = thresholdRosin(psd.A(:));  
end
psd.s = psd.A > psd.T;
psd.s2 = mask(sub2ind(size(I_npc),round(psd.y),round(psd.x)));
psd.s3 = psd.s&psd.s2;

% Plot NPCs
hfig = figure;
imshow(I_npc,[]);
hold on;
scatter(psd.x(psd.s3),psd.y(psd.s3));
title(md_title, 'interpreter', 'none');
saveas(hfig,'NPC_detection.fig');
saveas(hfig,'NPC_detection.png');

% Find Distance between lamin and NPC
[~,D] = knnsearch(LL,[psd.x(psd.s3).' psd.y(psd.s3).']);

% Find random distance distribution
rxy = rand(60000,2)*1024;
maskch = regionprops(mask,'ConvexHull');
rxyip = inpolygon(rxy(:,1),rxy(:,2),maskch.ConvexHull(:,1),maskch.ConvexHull(:,2));
rxy = rxy(rxyip,:);
[~,rD] = knnsearch(LL,rxy);

% Pair histogram figure
hfig = figure; h = histogram(D.*MD.pixelSize_,0:10:(max(D.*MD.pixelSize_)+10),'Normalization','probability');
hold on; h2 = histogram(rD.*MD.pixelSize_,h.BinEdges,'Normalization','probability');
xlabel('NPC - Lamin Nearest Neighbor Distance (nm)');
ylabel('Probability');
title(md_title, 'interpreter', 'none');
saveas(hfig,'NPC-Lamin_Distance_Pair_Histogram.fig');
saveas(hfig,'NPC-Lamin_Distance_Pair_Histogram.png');


% Delta Histogram Figure
hfig = figure; bar(h.BinEdges(1:end-1)+5,h.Values - h2.Values);
xlabel('NPC - Lamin Nearest Neighbor Distance (nm)');
ylabel('Probability Difference From Random');
ylim([-0.04 0.04]);
title(md_title, 'interpreter', 'none');
saveas(hfig,'NPC-Lamin_Distance_DifferenceFromRandom.fig');
saveas(hfig,'NPC-Lamin_Distance_DifferenceFromRandom.png');

% Show Lamin and NPC colocation
hfig = figure;
imshowpair(I,imadjust(I_npc));
hold on; plot(LL(:,1),LL(:,2),'y.');
hold on; scatter(psd.x(psd.s3),psd.y(psd.s3),'c.');
title(md_title, 'interpreter', 'none');
saveas(hfig,'NPC-Lamin_Detection.fig');
saveas(hfig,'NPC-Lamin_Detection.png');


%% Face centroid calculations

Ld = bwdist(nlms_mip > T);
faceCenterBW = (imdilate(Ld,strel('disk',5)) == Ld).*mask;
faceCenterCC = bwconncomp(faceCenterBW);
facerp = regionprops(faceCenterCC,'Centroid');
faceCenterCentroids = vertcat(facerp.Centroid);

lamin_npc_dist = D;
[~,fD] = knnsearch(faceCenterCentroids,[psd.x(psd.s3).' psd.y(psd.s3).']);
[~,frD] = knnsearch(faceCenterCentroids,rxy);

bins2d = 0:10:250;

hfig = figure;
marginal_ax(1) = subplot(2,2,1);
histogram(D.*MD.pixelSize_,bins2d,'Normalization','probability')
hold on; h2 = histogram(rD.*MD.pixelSize_,bins2d,'Normalization','probability');
ylabel('Freq');

main_ax = subplot(2,2,3);
histogram2(D*MD.pixelSize_,fD*MD.pixelSize_,bins2d,bins2d,'DisplayStyle','tile');
hold on;
plot(D*MD.pixelSize_,fD*MD.pixelSize_,'k.','MarkerSize',0.1);
xlim([0 bins2d(end)]);
ylim([0 bins2d(end)]);
xlabel('NPC - Lamin Distance (nm)');
ylabel('NPC - Face center Distance (nm)');

marginal_ax(2) = subplot(2,2,4);
histogram(fD.*MD.pixelSize_,bins2d,'Orientation','horizontal','Normalization','probability');
hold on; h2 = histogram(frD.*MD.pixelSize_,bins2d,'Orientation','horizontal','Normalization','probability');
xlabel('Freq');

deltay = marginal_ax(1).Position(4)-0.1;
deltax = marginal_ax(2).Position(3)-0.1;

marginal_ax(1).Position = marginal_ax(1).Position + [0 deltay deltax -deltay];
marginal_ax(2).Position = marginal_ax(2).Position + [deltax 0 -deltax deltay];
main_ax.Position = main_ax.Position +[0 0 deltax deltay];

saveas(hfig,'hist2d_npcs_to_lamins_and_faces.fig');
saveas(hfig,'hist2d_npcs_to_lamins_and_faces.png');

hfig = figure;
marginal_ax(1) = subplot(2,2,1);
histogram(rD.*MD.pixelSize_,bins2d,'Normalization','probability','FaceColor',[0.8500 0.3250 0.0980]	);
ylabel('Freq');


main_ax = subplot(2,2,3);
histogram2(rD*MD.pixelSize_,frD*MD.pixelSize_,bins2d,bins2d,'DisplayStyle','tile')
xlabel('NPC - Lamin Distance (nm)');
ylabel('NPC - Face center Distance (nm)');

marginal_ax(2) = subplot(2,2,4);
histogram(frD.*MD.pixelSize_,bins2d,'Orientation','horizontal','Normalization','probability','FaceColor',[0.8500 0.3250 0.0980]	);
xlabel('Freq');


marginal_ax(1).Position = marginal_ax(1).Position + [0 deltay deltax -deltay];
marginal_ax(2).Position = marginal_ax(2).Position + [deltax 0 -deltax deltay];
main_ax.Position = main_ax.Position +[0 0 deltax deltay];

saveas(hfig,'hist2d_npcs_to_lamins_and_faces_rand.fig');
saveas(hfig,'hist2d_npcs_to_lamins_and_faces_rand.png');

imwrite(imfuse(I,I_npc),'fused.png');
imwrite(imfuse(imadjust(I),imadjust(I_npc)),'adjusted_fused.png');

save('analyzeLaminsNPCdistance.mat','D','rD','psd','mask','LL','T','fD','frD');

% keyboard;

end

