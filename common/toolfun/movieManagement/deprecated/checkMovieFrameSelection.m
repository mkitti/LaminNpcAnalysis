function isOkay = checkMovieFrameSelection(movieData)

%{

movieHasFrameSelection = checkMovieFrameSelection(movieData);
or
[movieHasFrameSelection,iFrames] = checkMovieFrameSelection(movieData);

Checks whether a sub-set of the frames in the movie are to be used as specified by using selectMovieFrames.m

Hunter Elliott, 4/2009

%}

movieData = setupMovieData(movieData);

isOkay = false;

if isfield(movieData,'selectedFrames') && isfield(movieData.selectedFrames,'status') && movieData.selectedFrames.status == 1 ...
        && isfield(movieData.selectedFrames,'iFrames')
    isOkay = true;
end
