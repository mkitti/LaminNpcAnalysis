function copyFilesForTransfer(movieArray,fileNames,destinationDir)

% 
% copyMoviesForTransfer(movieArray,movieNames,destinationDirectory)
% 
% Goes through the analysis folders for the movies in movieArray and 
% copies the files with names specified by fileNames into the folder
% destinationDir with new individual names for transfer/upload 
% to another computer.
% Each file (which must be identically named in each movie's analysis folder)
% will be given a new name (which includes the movie's folder) for copying
% 
% 
% Hunter Elliott, 4/2009
% 



nMovies = length(movieArray);
nFileNames = length(fileNames);

%Check destination directory
if ~exist(destinationDir,'dir')
    error('Specified destination directory does not exist! Please check or create!')
end

for iMov = 1:nMovies
    
    
    for iFile = 1:nFileNames
    
        %Check the movieData
        movieArray{iMov} = setupMovieData(movieArray{iMov});
        
        if exist([movieArray{iMov}.analysisDirectory filesep fileNames{iFile}],'file')
            
            %Get the folder name
            iSlash = regexp(movieArray{iMov}.analysisDirectory,filesep);            
            %Extract the dataset and movie folders from this
            dirName = [movieArray{iMov}.analysisDirectory(iSlash(end-1)+1:iSlash(end)-1) '_' movieArray{iMov}.analysisDirectory(iSlash(end)+1:end)];
            
            
            
            copyfile([movieArray{iMov}.analysisDirectory filesep fileNames{iFile}],[destinationDir filesep dirName '_' fileNames{iFile}]);
            
            %copyfile([movieArray{iMov}.analysisDirectory filesep fileNames{iFile}],[destinationDir filesep dirName '_average activity extrema.fig']);
    
    
        else
            disp(['Couldn''t find file ' fileNames{iFile} ' in folder ' movieArray{iMov}.analysisDirectory])
            disp(['for movie number ' num2str(iMov)])
        end
    
    end
    
end