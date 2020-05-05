function padImageSequenceSetup(inputDir, varargin)
%This function finds the appropriate folders to run a batch of
%padImageSequence() functions. 
% overall directory is required. The primary and secondary directories can
% be specified separately as well. In addition, the user can specify an
% output name for the files to be used in padImageSequence. Otherwise, the
% default is 'ChannelExpanded'. 

%-Jessica Tytell December 7, 2011

% parse input
ip = inputParser;
ip.addRequired('inputDir', @ischar);
ip.addOptional('primeChan', 'images', @ischar);
ip.addOptional('secChan', ['hdrMerge' filesep 'logMysteryTIFFs'], @ischar); 
ip.addOptional('foldName', 'VimentinFullSeq', @ischar);
ip.parse(inputDir, varargin{:});
primeChan = ip.Results.primeChan;
secChan = ip.Results.secChan;
foldName = ip.Results.foldName;


%Get the folders for each movie
movieFolders = dir([inputDir filesep 's*']);
movieFolders = movieFolders(arrayfun(@(x)(x.isdir && ... %Retain only the directories. Do it this way so it works on linux and PC
    ~(strcmp(x.name,'.') || strcmp(x.name,'..'))),movieFolders));
 

nMovies = length(movieFolders);

%loop through movies
for j = 1:nMovies
    
    disp(['Processing folder ' num2str(j) ' of ' num2str(nMovies)])
    
    %Get current folder path for readability
    currDir = [inputDir filesep movieFolders(j).name];
    disp(currDir);
    
    %exit loop if files already exist - no overwrite allowed.
    if exist([currDir filesep foldName], 'dir')
        disp('Expanded file already exists. No override function exists, please delete file and start again');
        continue;
    else
        %get base and intermittent file directories
        baseDir = [currDir filesep primeChan];
        intermitDir = [currDir filesep secChan];
        disp(baseDir);
        disp(intermitDir);
        
        %exit loop with warning if no images in directory
        if isempty(baseDir) || ~exist(baseDir, 'dir');
            disp('Main image folder is empty: Please try again');
        elseif isempty(intermitDir) || ~exist(intermitDir, 'dir');
            disp('Secondary image folder is empty: Please try again');
        else
            
            %send to padImageSequence
            padImageSequence(baseDir, intermitDir, foldName);
        end
        
    end
end