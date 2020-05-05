function movieData = autoVerifyMovieSegmentation(movieData,varargin)

% movieData = validateMovieMasks(movieData)
%
% movieData = validateMovieMasks(movieData,'OptionName',optionValue,...)
%
% This function performs a series of checks on the masks for the input
% movie. This is accomplished by checking changes in the mask area (from
% channel to channel and/or from frame to frame).
%
% 
% Possible Options:
% 
% 'ChannelIndex' - Indices of channels to check masks for. Positive integer
% scalar or vector. Optional. If not specified, all channels which have
% masks will be checked.
%
% 'MaxAreaDiffTime' - Maximum allowed fractional change in mask area between
% frames. That is, if  
%     abs(change in mask area from frame n to n+1)/(mask area in frame n) 
% is greater than this value for any two consecutive frames, the masks will
% fail validation. Default is .15
%
% 'MaxAreaDiffChannel' - Maximum allowed fractional difference in mask areas
% between channels on any given frame. Optional. Default is .15
%
% 'BatchMode' - If true, all graphical output will be suppressed (including
% progress bars, figures etc.). Optional. Default is false;
%
%
%
% Output:
%
%   The validation results will be stored in the movieData field
%   "classification" in a sub-field called "autoVerifyMasks" 
%
% Hunter Elliott, 11/2009
%
%% ----- Parameters ---- %%

fileName = 'mask_validation_stats.mat'; %File name for saving mask statistics and detected bad frames.

%% --------- Input ------------ %%

%Check the movieData
movieData = setupMovieData(movieData);

%Parse variable input arguments
[iChannels,maxDAreaDt,maxDAreaDc,batchMode] = parseInput(varargin);

% --- Check inputs/set defaults ---- %

%If channels were not requested, check all that have masks
if isempty(iChannels)
   iChannels = find(cellfun(@(x)(~isempty(x)),movieData.masks.channelDirectory));
end
%Check these masks
if isempty(iChannels) || ~checkMovieMasks(movieData,iChannels)
    error('Must create movie masks before validating them!')
end

if isempty(maxDAreaDt)
    maxDAreaDt = .15;
end

if isempty(maxDAreaDc)
    maxDAreaDc = .15;
end

if isempty(batchMode)
    batchMode = false;
end


%% ----------- Init ------------- %%

%Get number of channels to check masks for
nChan = length(iChannels);

%Get the mask file names and directories for each channel to be checked
maskFileNames = getMovieMaskFileNames(movieData,iChannels);

%Check that the mask channels to be checked have the same number of masks
if length(unique(movieData.nImages(iChannels))) > 1
    error('Can only simultaneously check mask channels with the same number of images!')
end

nImages = movieData.nImages(iChannels(1));


maskAreas = zeros(nImages,nChan);
deltaMaskAreaT = zeros(nImages,nChan); %Area difference between frames
deltaMaskAreaC = zeros(nImages,nChan-1);%Area difference between channels



%% ------------ Get Mask Statistics-----------%%
% As of now, the "statistics" are just the areas in each frame and change
% in areas

disp('Please wait, checking masks...')


if ~batchMode
    wtBar = waitbar(0,'Please wait, checking movie masks...');
end

for iImage = 1:nImages
                
    %Go through each channel and get the areas in each frame
    for iChan = 1:nChan    
        currMask = imread(maskFileNames{iChan}{iImage});        
        maskAreas(iImage,iChan) = sum(currMask(:));    
    end
    
    %Check the area differences between the channels
    if nChan > 1 
        deltaMaskAreaC(iImage,:) = abs(1 - maskAreas(iImage,2:end) ./ maskAreas(iImage,1));       
    end
    
    %Check the area difference between this and the last frame
    if iImage > 1 
        deltaMaskAreaT(iImage,:) = abs(1 - maskAreas(iImage-1,:) ./ maskAreas(iImage,:));               
        
    end    
    
    if ~batchMode && mod(iImage,5) == 0
        waitbar(iImage/nImages,wtBar)
    end
    
end


%% -------- Check Mask Statistics ------ %%

%Find the frames where the area changed too much between frames
iBadFrames = find(max(deltaMaskAreaT,[],2) > maxDAreaDt);

%Find the frames where the channel areas dissagreed
iBadFrames = [iBadFrames' find(max(deltaMaskAreaC,[],2) > maxDAreaDc)'];

%Get rid of duplications
iBadFrames = sort(unique(iBadFrames));

if isempty(iBadFrames)
    disp('All masks passed validation!')
else
    disp(['Problems found with masks! Check the file ' fileName ...
        ' in movie analysis directory for bad frames.'])
end


%% ------- Make and save validation figures ----- %%


if batchMode
    figHan = figure('Visible','off');
else
    figHan = figure;
end


subplot(3,1,1)
hold on
ylabel('Mask Area (pixels)')
plot(maskAreas)
legend(movieData.channelDirectory{iChannels})

subplot(3,1,2)
hold on
ylabel('Fractional Change in Mask Area')
plot(deltaMaskAreaT)
legend(movieData.channelDirectory{iChannels})

subplot(3,1,3)
hold on
ylabel('Fractional difference between channels')
xlabel('Frame #')
plot(deltaMaskAreaC)



%% ------- Output ------%%


if isempty(iBadFrames)
    movieData.classification.autoVerifyMasks = {'Good'};
else
    movieData.classification.autoVerifyMasks = {'Bad'};    
end

dateTime = datestr(now); %#ok<NASGU>

%Save the statistics/bad frames to file.
save([movieData.analysisDirectory filesep fileName],'iBadFrames','iChannels',...
    'dateTime','maxDAreaDt','maxDAreaDc','maskAreas','deltaMaskAreaT','deltaMaskAreaC');

%Save the figure also
hgsave(figHan,[movieData.analysisDirectory filesep 'mask_validation_figure.fig']);

updateMovieData(movieData)


if ~batchMode && ishandle(wtBar)
    close(wtBar);
end


function [iChannels,maxDAreaDt,maxDAreaDc,batchMode] = parseInput(argArray)
%Parse the variable input arguments


% ---- Init ----%
iChannels = [];
maxDAreaDt = [];
maxDAreaDc = [];
batchMode = [];


if isempty(argArray)
    return
end

nArg = length(argArray);

if mod(nArg,2) ~= 0    
    error('Inputs must be as optionName/ value pairs!')
end

for i = 1:2:nArg
    
   switch argArray{i}                     
              
       case 'ChannelIndex'           
           iChannels = argArray{i+1};
           
       case 'MaxAreaDiffTime'
           maxDAreaDt = argArray{i+1};
           
       case 'MaxAreaDiffChannel'
           maxDAreaDc = argArray{i+1};
           
       case 'BatchMode'
           batchMode = argArray{i+1};
           
       otherwise
       
           error(['"' argArray{i} '" is not a valid option name! Please check input!'])
   end
               
      
   
end


