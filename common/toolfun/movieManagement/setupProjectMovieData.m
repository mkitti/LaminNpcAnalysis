function setupProjectMovieData(projectFolder,pixSize,timeInterval,forceReplace,identString)
%SETUPPROJECTMOVIEDATA sets up the movieData for a collection of movies with the same properties.
%
% setupProjectMovieData(projectFolder,pixSize,timeInterval)
% setupProjectMovieData(projectFolder,pixSize,timeInterval,forceReplace,identString)
%
%
% This function takes movie folders (which must be set up as done in
% setMosetupProjectImageFolders.m) and creates their movieData using the
% same pixel size and time interval on each. It assumes that each folder in
% the project directory contains one movie, and that the images for that
% movie are in a sub-directory titled "images"
%
%
% Input:
%   projectFolder - this is the folder which contains all the movie folders.
%   This is the same folder you specified when using setupMovieFolders.m
%
%   pixSize - image pixel size in nanometers for all movies in folder
%
%   timeInterval - time interval between images in seconds for all movies in
%   folder
%   
%   forceReplace - If true, a new movieData will be created even if there
%   is an existing one in the same directory. This will erase all
%   processing that has been logged in the movieData.
%   Optional. Default is false.
%
%   identString - A string identifying specific movie folders
%   (sub-directories of the project folder) to setup movieData for. Only
%   sub-folders with this identifying string somewhere in their name will
%   have movieData created. Optional. If not input, all sub-folders will be
%   used.
% 
% Output: 
% 
%   The newly created movieData structures will be saved in each movie's
%   analysis directory as a file named movieData.mat.
% 
% 
% Hunter Elliott 
% Re-written 7/2010
%


if nargin < 1 || isempty(projectFolder)
    error('You must specify a project directory, a time interval and a pixel size!')
end

if nargin < 2
    pixSize = [];
end

if nargin < 3
    timeInterval = [];
end

if nargin < 4 || isempty(forceReplace)
    forceReplace = false;
end

if nargin < 5 || isempty(identString)
    identString = [];
end

%Get the folders for each movie
movieFolders = dir([projectFolder filesep '*' identString '*']);
movieFolders = movieFolders(arrayfun(@(x)(x.isdir && ... %Retain only the directories. Do it this way so it works on linux and PC
    ~(strcmp(x.name,'.') || strcmp(x.name,'..'))),movieFolders)); 

   
nMovies = length(movieFolders);


%Go through each and try to set up the movieData
for j = 1:nMovies
            
    disp(['Setting up movie ' num2str(j) ' of ' num2str(nMovies)])           
    
    %Get current folder path for readability
    currDir = [projectFolder filesep movieFolders(j).name];
    
    clear chans;
    
    %Check for an existing movieData
    if forceReplace || ~exist([currDir filesep 'movieData.mat'],'file')
    
        %Look for sub-folder named "images"        
        if exist([currDir filesep 'images'],'dir')
            
                        
            %Check for sub directories containing the images for each
            %channel
            chanDir = dir([currDir filesep 'images']);
            chanDir = chanDir(arrayfun(@(x)(x.isdir && ... %Retain only the directories.
                            ~(strcmp(x.name,'.') || strcmp(x.name,'..'))),chanDir));
            
            %Check if it is a single- or multiple-channel movie and set up the channels            
            if ~isempty(chanDir)
            
                %Determine the number of images and image size in each channel
                %directory.
                nChanDir = numel(chanDir);
                for i = 1:nChanDir
                    %Find images in this directory
                    chans(i) = Channel([currDir filesep 'images' filesep chanDir(i).name]); %#ok<AGROW> Can't initialize due to private fields                    
                end                                                
                                
            else %If it's a single-channel movie...
                chans = Channel([currDir filesep 'images']);                
            end
            
            %Create the movieData            
            MD = MovieData(chans,currDir,'movieDataPath_',currDir,...
                'movieDataFileName_','movieData.mat','pixelSize_',pixSize,'timeInterval_',timeInterval);
            
            try
                %Make sure everything is legit before saving
                MD.sanityCheck
                MD.save;                
                disp('MovieData setup!')                                    
            catch errMess
                disp(['Problem setting up movie ' num2str(j) ' : ' errMess.message]);                    
            end
                            
        else
           disp(['Movie folder ' currDir ' has no sub-directory named "images" - cannot setup movieData!']) 
        end
    else
        disp(['Movie ' num2str(j) ' of ' num2str(nMovies) ' already had a movieData.mat! Doing nothing...'])
        
    end
end
