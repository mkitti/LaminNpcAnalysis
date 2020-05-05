function padImageSequence(baseFileDir, intermitDir, varargin)
%This function is designed to fill out a sequence of images where the
%smaller sequence is taken every N timepoints of the main images. It finds
%the closest time point from the main sequence and duplicates the
%appropriate corresponding image. It outputs to a new folder to allow for
%analysis with other programs.

% Jessica Tytell, December 7, 2011

% parse input
ip = inputParser;
ip.addRequired('baseFileDir', @ischar); 
ip.addRequired('intermitDir', @ischar);
ip.addOptional('outputName', 'ChannelExpanded', @ischar);
ip.parse(baseFileDir, intermitDir, varargin{:});
foldName = ip.Results.outputName;

%set location and make output dir
outputLocation = fileparts(baseFileDir);
outputDir = ([outputLocation filesep foldName]);
mkdir(outputDir);

%read in files and show in window
[baseFiles,~,baseTimes] = imDir(baseFileDir);
disp('baseFiles = ' );
disp(baseFiles);
[intermitFiles,~,intermitTimes] = imDir(intermitDir);
disp('intermittent Files = ');
disp(intermitFiles);

if isempty(baseTimes) || isempty(intermitTimes)
    error('One of the image directories is empty. Unfortunately this program does not work with theoretical data');
end

%write names to own array as string
baseNames = {baseFiles.name};
intermitNames = {intermitFiles.name};
[~, baseBody] = getFilenameBody(baseNames{1});
[~, intermitBody] = getFilenameBody(intermitNames{1});

%get length of longer file
nBase = length(baseNames);

%Find closest time index in the intermittent timepoints
intermitIndex=KDTreeClosestPoint(intermitTimes,baseTimes);

%add waitbar for impatient people (or people who don't trust this code)
h = waitbar(0,'Please wait...');



% Create formatted string for padding zeros
fString = ['%0' num2str(floor(log10(nBase))+1) '.f'];

for j = 1:nBase
    %get next file and read in
    nextIntFile = [intermitDir filesep intermitNames{intermitIndex(j)}];
    intermitIm = double(imread(nextIntFile));
    
    outputIm = uint16(intermitIm);
        
    %write file to new folder
    outputName= [outputDir filesep intermitBody '_exp_' num2str(baseTimes(j),fString) '.TIF'];
    imwrite((outputIm), outputName, 'tiff');
    
    %update waitbar
    waitbar(j / nBase)

end
close(h);

disp('<snoopy dance>');
    
    
    
     