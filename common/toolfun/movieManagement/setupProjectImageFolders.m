function setupProjectImageFolders(projectFolder,channelNames,folderNames)
%SETUPPROJECTIMAGEFOLDERS places images from different channels in their own directory based on their name
% 
% setupProjectImageFolders(projectFolder,channelNames) 
% setupProjectImageFolders(projectFolder,channelNames,folderNames) 
% 
% This function is designed to arrange the images for movies into
% individual folders, one-per-channel of the movie. It expects that each
% movie be in it's own folder, with all the image channels in that folder.
%
% Input:
% 
%     projectFolder - A parent directory containing all the movies to setup folders
%     for. Each movie should be in it's own sub-directory of this directory.
% 
%     channelNames - A cell array containing a string identifying each channel.
%     The string must be part of the image file names. For instance, if
%     channelNames was input as {'CFP','FRET'}, then every image file with
%     "CFP" in it's name will be put in a folder called "CFP" and every file
%     with "FRET" in it's name will be put in a folder named "FRET"
% 
%     folderNames - A cell array containing strings giving the names of the
%     folders each channel should be moved to. Must have one element for each
%     channel name.
%     Optional. If not input, channel names are used as folder names.
% 
% Revamped 4/2011
%

if nargin < 2 || isempty(channelNames)
    error('You must input both a folder and a channel-names array!')
end

if nargin < 3 || isempty(folderNames)
    folderNames = channelNames;
end

nChan = length(channelNames);

%Get the folders for each movie
movieFolders = dir(projectFolder);
movieFolders = movieFolders(arrayfun(@(x)(x.isdir && ... %Retain only the directories. Do it this way so it works on linux and PC
    ~(strcmp(x.name,'.') || strcmp(x.name,'..'))),movieFolders)); 
nMovies = length(movieFolders);

if nMovies == 0
    error('No valid movie folders found in specified parent directory!')
end


%Go through each folder and set up the image folders
for j = 1:nMovies
        
    
    disp(['Setting up movie ' num2str(j) ' of ' num2str(nMovies)])
    
           
    for k = 1:nChan
        
        %Find all images in this directory
        imFiles = imDir([projectFolder filesep movieFolders(j).name]); %This is within the loop as a workaround for files which match more than one channel name... HLE    
        
        %Look for files fitting the current string        
        currMatches = arrayfun(@(x)(~isempty(regexp(x.name,channelNames{k},'ONCE'))),imFiles);
                        
        if sum(currMatches) > 0
            
            %Make this channel's directory
            mkdir([projectFolder filesep movieFolders(j).name filesep folderNames{k}]);
            
            %Move all the matching images into it.
            arrayfun(@(x)(movefile(...
                [projectFolder filesep movieFolders(j).name filesep x.name],...
                [projectFolder filesep movieFolders(j).name filesep folderNames{k} filesep x.name])),imFiles(currMatches));
            
        else
            
            disp(['Couldnt find any images matching channel "' channelNames{k} '"!'])
        end
   
   
    end
    
    
end
