    function movieData = manualVerifyMovieSegmentation(movieData,iChannels)
%MANUALVERIFYMOVIESEGMENTATION allows the user to judge the mask quality by viewing a movie overlay
%
%
% movieData = manualValidateMovieMasks(movieData,iChannels)
% 
% This function shows a movie overlaying the mask outline on the
% fluorescence in every frame. The user can then subjectively decide
% whether the masks are of "Good", "Mediocre" or "Bad" quality, and
% classify the movie accordingly.
%
% 
% Input:
% 
%   movieData - The movieData structure describing the movie.
%
%   iChannels - The indices of the mask channels to verify. Positive
%                  integer. Optional - if not input, the user will be
%                  asked.
%
% Output:
%
%   movieData - The updated movieData with the user's evluation stored in it
%               in the field movieData.classification.manualVerifyMasks
%
% Hunter Elliott, 10/2009
%

%% ----------- Init -------- %%


%Check the movieData
movieData = setupMovieData(movieData);

if nargin < 2
    iChannels = [];
end

%Check that the segmentation has been completed successfully:
if ~checkMovieMasks(movieData,iChannels)
    error('You must run segmentation first! Check movieData or re-run segmentMovie.m!')
end



%% ------- User verification of Segmentation via Mask Movie ------ %%


%Check that the mask movie has been made
if ~checkMovieMaskMovie(movieData)
    disp('Mask movie has not been made yet, making movie...')
    movieData = makeMaskMovie(movieData,'ChannelIndex',iChannels);    
    
    %Check that it succeeded
    if ~checkMovieMaskMovie(movieData)
        error('Must make mask movie with makeMaskMovie.m to continue!')
    end    
end 

%Compare the date/time on the segmentation and the mask movie
if datenum(movieData.masks.dateTime) > datenum(movieData.movies.maskMovie.dateTime)
    bPressed = questdlg('The segmentation is newer than the mask movie!',...
        'User Mask Validation','Re-Make Movie','Ignore','Abort','Abort');
    
    switch bPressed
        
        case 'Re-Make Movie'
            
            movieData = makeMaskMovie(movieData,'ChannelIndex',iChannels);
            
        case 'Abort'
            
            return
    end
end



%  Open the mask movie

%Tell the user what's going on:
mb=msgbox('Please view the mask movie, and then close the viewing application when finished.','modal');
uiwait(mb);

if ispc
    fStat = system([movieData.analysisDirectory filesep movieData.movies.maskMovie.fileName]);        
    
elseif isunix
    cd(movieData.analysisDirectory)
    fStat = system(['totem '  movieData.movies.maskMovie.fileName]); %not ideal, but what else?
end

if fStat ~= 0
    error('Problem displaying mask movie!')
end

%Ask the user how the masks looked
bPressed = questdlg('How did the masks look?','User Mask Validation','Good','Mediocre','Bad','Bad');

if ~isempty(bPressed) %As long as the user didn't click cancel, 
    %store the classification in the moviedata.    
    movieData.classification.manualVerifyMasks = {bPressed};          
end
    

%Save the movieData
updateMovieData(movieData);

