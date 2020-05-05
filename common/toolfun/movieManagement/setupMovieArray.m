function movieArray = setupMovieArray(parentDirectory,all)
%SETUPMOVIEARRAY creates an array of MovieData objects by searching through a directory
% 
% movieArray = setupMovieArray;
% movieArray = setupMovieArray(parentDirectory);
% movieArray = setupMovieArray(parentDirectory,all);
%
% 
% This function finds the MovieData object file for every movie in the
% specified parent directory and its sub-directories, and then allows the
% user to select which ones to load. These MovieData objects should be
% saved in files named movieData.mat, and should be formatted as created by
% setupMovieDataGUI.m
% 
% Input:
% 
%   parentDirectory - character array specifying the directory to
%   recursively search for movieData files.
% 
%   all - true/false. If true, all movieData objects found in the directory
%   are returned. If false, the user is asked to select from the movieData
%   files that were found.
%   Optional. Default is false.   
%
% Output:
% 
%   movieArray - A cell-array containing all the movieData structures for
%   the movies in the parent directory.
%
%
%
% Hunter Elliott
% Sometime in 2008?


%Get the parent directory if not input
if nargin < 1 || isempty(parentDirectory)
    parentDirectory = uigetdir('','Select the parent directory containing all the movies:');
end

if nargin < 2 || isempty(all)
    all = false;
end

%Search for movie data files in this directory

if parentDirectory == 0 %if user clicked cancel
    movieArray = [];
    return
else
    fList = searchFiles('movieData.mat',[],parentDirectory,1,'new',1);
end

if isempty(fList) 
    error('No movieData.mat files found in specified directory! Check directory!')    
end

if ~all
    %Allow the user to select among the files found
    [iSel,selectedFiles] = listSelectGUI(fList,[],'move');
else
    selectedFiles = fList;
    iSel = 1:numel(selectedFiles);
end    

if ~isempty(iSel)
    %Load all of the movie data files and put them in an array
    nFiles = length(selectedFiles);

    %movieArray = MovieData(1,nFiles); Not sure how to pre-allocate without
    %running into access problems with private fields...

    isGood = true(nFiles,1);
    for j = 1:nFiles

        tmp = load(selectedFiles{j});
        fNames = fieldnames(tmp);
        if numel(fNames) > 1 || ~isa(tmp.(fNames{1}),'MovieData');
            disp(['Invalid MovieData found at ' selectedFiles{j} ' - Not including in array! Please check this movieData.mat file!']);
            isGood(j) = false;
        else
            movieArray(j) = tmp.(fNames{1});
        end

    end

    movieArray = movieArray(isGood);
else
    movieArray = [];
end
