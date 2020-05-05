function cropChannels(applyMask)
% CROPCHANNELS crops all images for multiple channels with user-selected
% mask

% applyMask = 0 (default) to make a rectangular region circumscribing
% user-defined mask; 1 to retain polygon shape with 0's outside


if nargin<1
    applyMask=0;
end

% find existing /images and /roi_x directories. "images" directories make
% up the list of all the projects; "roi_x" ones have already been analyzed
topDir=uigetdir(pwd,'Please select top-level directory containing images directories');
p=genpath(topDir);
if ispc
    tempDirList=strrep(p,';',' ');
else
    tempDirList=strrep(p,':',' ');
end
imageDirList=regexp(tempDirList,['\S*images\s'],'match')'; % cell array of "images" directories
roiDirList  =regexp(tempDirList,['\S*roi_\d\s'],'match')'; % cell array of "roi" directories


% define image and roi directories
i=1;
imDir=imageDirList{i,1}(1:end-1);
roiDir=[imDir(1:end-7) filesep 'roi'];

% make new roi directory
mkdir(roiDir);

% get list and number of images
[listOfImages]=searchFiles('.tif',[],imDir,0);

% read first image
img=double(imread([char(listOfImages(1,2)) filesep char(listOfImages(1,1))]));
img=(img-min(img(:)))./(max(img(:))-min(img(:)));

roiMask=[];
while isempty(roiMask)
    try
        % draw polygon to make mask
        [roiMask,polyXcoord,polyYcoord]=roipoly(img);
    catch
        disp('Please try again.')
    end
end
close
roiYX=[polyYcoord polyXcoord; polyYcoord(1) polyXcoord(1)];

minY=floor(min(roiYX(:,1)));
maxY=ceil(max(roiYX(:,1)));
minX=floor(min(roiYX(:,2)));
maxX=ceil(max(roiYX(:,2)));

% save original and cropped roiMask
imwrite(roiMask,[topDir filesep 'roiMask.tif']);
save([topDir filesep 'roiYX'],'roiYX');

if applyMask==1
    M=roiMask(minY:maxY,minX:maxX);
else
    M=ones(size(roiMask(minY:maxY,minX:maxX)));
end

for i=1:length(imageDirList) % iterate through projects

    imDir=imageDirList{i,1}(1:end-1);
    roiDir=[imDir(1:end-7) filesep 'roi'];

    if ~isdir(roiDir)
        mkdir(roiDir);
    end

    % get list and number of images
    [listOfImages]=searchFiles('.tif',[],imDir,0);
    for j=1:size(listOfImages,1)
        imgName=[char(listOfImages(j,2)) filesep char(listOfImages(j,1))];
        img=double(imread(imgName));

        img=M.*img(minY:maxY,minX:maxX);
        img=uint16(img);
        imwrite(img,[roiDir filesep char(listOfImages(j,1))]);
    end

end % iterate through projects