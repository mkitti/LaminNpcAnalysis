function movieData = cropMovieOld(movieData,paramIn)
%CROPMOVIE allows the user to crop the images in the channel(s) of the movie described by the input movieData
%
% Syntax:
%
% movieData = cropMovie(movieData);
% movieData = cropMovie(movieData,paramIn)
% 
% Description:
% 
% This function allows the user to select a sub-region of the image(s) in
% the channel(s) of the input movie and NEED TO FINISH
%
% Input: 
%
%   cropPoly - The polygon to use to crop  the movie. Optional. If not
%   input, the user is asked to create. 
% 
% 
%   cropChannels - The integer index of the channels to crop.
% 
%   viewChannels - The integer index of the channel to view for interactive
%   cropping
%   
%   parentDir   -   The directory to write the cropped images and the new
%   movieData to.
% 
% Hunter Elliott,
% Re-Written 2/2011
% 


%STILL IN PROCESS OF CONVERTING - STOPPED HERE



%% ------ Parameters ------ %%%

nFrames = 3;%Number of frames to preview for cropping


%% ----- Input ----- %%

if nargin < 1
    %If no movieData is input, the user is asked to select an analysis
    %directory and an image directory below when the moviedata is setup
   movieData = [];
end

if nargin < 3 || isempty(cropChannels)
    %If no channels were input, ask the user which ones to crop    
    [cropChannels,OK] = listdlg('PromptString','Which channel(s) do you want to crop?',...
            'SelectionMode','multiple','ListString',movieData.channelDirectory);
    if ~OK
        return
    end
end

if nargin < 4 || isempty(viewChannels)
    viewChannels = cropChannels(1); %Default is to only view first channel
end

if nargin < 5
    parentDir = [];
end

%Set up and verify the movie data.
movieData = setupMovieData(movieData,'ROI');

nCrop = length(cropChannels);
nView = length(viewChannels);

if nView > 3
    error('You can only view up to 3 channels during cropping!')
end

axHandles = zeros(1,nFrames);

%Check if the movie has masks for the channels to be cropped
hasMasks = arrayfun(@(x)(checkMovieMasks(movieData,x)),cropChannels);

%If no polygon was input, ask the user to click one
if nargin < 2 || isempty(cropPoly)
    
    retryCrop = true;
    firstTime = true;
    while retryCrop
    
        if firstTime
            %First display images from the movie
            iFrames = round(linspace(1,movieData.nImages(cropChannels(1)),nFrames));
            for j =  1:nFrames                                        
                axHandles(j) = subplot(1,nFrames,j);
                hold on
                if j == 1
                    title(movieData.analysisDirectory,'Interpreter','none')
                end
                
                imFig = imageViewer(movieData,'AxesHandle',axHandles(j),'Frame',iFrames(j)...
                    ,'Channel',movieData.channelDirectory(viewChannels));
                hold on;
                
            end            
            firstTime = false;
        end
        %Let the user click a crop outline in the first image of first channel             
        pHan = impoly(axHandles(1));        
        cropPoly = getPosition(pHan);
        delete(pHan);
        %Now draw this polygon on all the frames
        for j =  1:nFrames
            set(imFig,'CurrentAxes',axHandles(j))
            fill(cropPoly(:,1),cropPoly(:,2),'r','FaceAlpha',.15,'EdgeColor','r')                                
        end
    
        %Ask the user if they like their crop or not        
        button = questdlg('Do you like your crop selection?','Confirmation','Yes, Crop Away!','No, Let me try Again.','Abort!','Abort!');
        
        switch button
            
            case 'Yes, Crop Away!'
                retryCrop = false;                            
                
            case 'Abort!'
                return
        end
        
        
    end        
    
end

%% ------ Cropping ----- %%
%Go through each requested channel and each image and crop them


if isempty(parentDir) % if no directory input...
    %Ask the user where they want to put the cropped images
    parentDir = uigetdir(pwd,'Select parent directory for new ROI:');
end
%Make directory for images if necessary
if ~exist([parentDir filesep 'images'],'dir')
    mkdir([parentDir filesep 'images'])
else
    %Delete the old images
    try %TEMP TEMP yeah I know but I'm tired... HLE
        rmdir([parentDir filesep 'images'],'s')
    catch        
    end
    mkdir([parentDir filesep 'images'])
    
end

roiMovieData.imageDirectory = [parentDir filesep 'images'];

wtBar = waitbar(0,'Please wait, cropping images....');

%Get current image file names    
imNames = getMovieImageFileNames(movieData,cropChannels);

%Make a mask directory if needed
if any(hasMasks)
    mkdir([parentDir filesep 'masks']);
    roiMovieData.masks.directory = [parentDir filesep 'masks' ];
    roiMovieData.masks.dateTime = movieData.masks.dateTime;
    roiMovieData.masks.iFrom = movieData.masks.iFrom;
    roiMovieData.masks.status = movieData.masks.status;
end



%Go through the images
for iChan = 1:nCrop
    
    
    nImages = length(imNames{iChan}); %Allow variable image # per channel
    
    %Store the channel names in the ROI's movieData
    roiMovieData.channelDirectory{cropChannels(iChan)} = movieData.channelDirectory{cropChannels(iChan)};
    
    %Make the channel directory
    mkdir([roiMovieData.imageDirectory filesep roiMovieData.channelDirectory{cropChannels(iChan)}])
    
    %Make the mask directory if necessary
    if hasMasks(iChan)                
        roiMovieData.masks.channelDirectory{cropChannels(iChan)} = ...
            movieData.channelDirectory{cropChannels(iChan)};
        mkdir([roiMovieData.masks.directory filesep ... 
            roiMovieData.masks.channelDirectory{cropChannels(iChan)}]);
        maskNames = getMovieMaskFileNames(movieData,cropChannels(iChan));
    end
    
    for iFrame = 1:nImages
        
        %Load the current image
        currIm = imread(imNames{iChan}{iFrame});
        
        if iFrame == 1
            [imageM,imageN] = size(currIm);                        
            %Get mask from the polygon
            mask = poly2mask(cropPoly(:,1),cropPoly(:,2),imageM,imageN);
        end
        
        %Crop the image
        currIm(~mask) = 0;
        
        %Remove "extraneous" areas that are outside the crop
        currIm = currIm(max(1,floor(min(cropPoly(:,2) ) ))  : min(ceil(max(cropPoly(:,2) ) ),imageM), ...
                                  max(1,floor(min(cropPoly(:,1) ) ))  : min(ceil(max(cropPoly(:,1) ) ),imageN));
        
        %Write it to the new image directory
        iLastSep = max(regexp(imNames{iChan}{iFrame},filesep));
        imwrite(currIm,[roiMovieData.imageDirectory filesep roiMovieData.channelDirectory{cropChannels(iChan)} filesep 'crop_' imNames{iChan}{iFrame}(iLastSep+1:end)]);
        
        if hasMasks(iChan)
            currMask = imread(maskNames{1}{iFrame});
            currMask(~mask) = false;
            currMask = currMask(max(1,floor(min(cropPoly(:,2) ) ))  : min(ceil(max(cropPoly(:,2) ) ),imageM), ...
                                  max(1,floor(min(cropPoly(:,1) ) ))  : min(ceil(max(cropPoly(:,1) ) ),imageN));
            iLastSep = max(regexp(maskNames{1}{iFrame},filesep));
            imwrite(currMask,[roiMovieData.masks.directory filesep roiMovieData.masks.channelDirectory{cropChannels(iChan)} filesep 'crop_' maskNames{1}{iFrame}(iLastSep+1:end)]);
        
        end
        waitbar( (nImages*(iChan-1) + iFrame ) / (nImages*nCrop),wtBar)
        
    end
    
    
end

close(wtBar);

%% ------- ROI Movie Data Setup ------ %%
%Sets up the movieData for the newly created ROI

%Check if there is a movieData present in the ROI directory, and if not set
%it up.



%Transfer basic movie info from parent images
roiMovieData.pixelSize_nm = movieData.pixelSize_nm;
roiMovieData.timeInterval_s = movieData.timeInterval_s;
roiMovieData.nImages = movieData.nImages;
roiMovieData.imageDirectory = [parentDir filesep 'images'];

if isfield(movieData,'stimulation')
    roiMovieData.stimulation = movieData.stimulation;
end

%TEMP - assume that parent is analysis dir
roiMovieData.analysisDirectory = parentDir;

%Save the ROI's movieData
updateMovieData(roiMovieData);

%Record that an ROI was cropped from the movie in the original movie's
%movieData
nExisting = 0;
if isfield(movieData,'ROI') && isfield(movieData.ROI(1),'analysisDirectory')%If it's been cropped before
    nExisting = length(movieData.ROI);
    isOld = false(1,nExisting);
    for j = 1:nExisting
        if isfield(movieData.ROI(j),'analysisDirectory')
            %Check if this is a re-crop of an existing ROI
            isOld(j) = strcmp(roiMovieData.analysisDirectory,movieData.ROI(j).analysisDirectory);                    
        end
    end
end
     
if exist('isOld','var') 
    if sum(isOld) == 1 %if it found one match        
        iRoi = find(isOld);
    elseif sum(isOld) == 0  %If there was no match but there are previous crops
        iRoi = nExisting  + 1;
    elseif sum(isOld) > 1
        error('Duplicate crops specified in movieData - please check!!')
    end
else %If this is the first crop
    iRoi = 1;
end
    

movieData.ROI(iRoi).analysisDirectory = roiMovieData.analysisDirectory;
movieData.ROI(iRoi).imageDirectory = roiMovieData.imageDirectory;
fName = ['crop data ROI ' num2str(iRoi) '.mat'];
movieData.ROI(iRoi).fileName = fName;
%Save the crop info to the ROI directory
save([movieData.ROI(1).directory filesep fName ],'movieData','cropPoly','cropChannels','imageM','imageN')

movieData.ROI(iRoi).status = 1;
movieData.ROI(iRoi).dateTime = datestr(now);

%Save the input movieData
updateMovieData(movieData)


