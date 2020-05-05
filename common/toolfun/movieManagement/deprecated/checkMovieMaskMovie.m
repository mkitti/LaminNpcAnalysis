function status = checkMovieMaskMovie(movieData)

% status = checkMovieMaskMovie(movieData)
% 
% This function checks whether a mask movie has been successfully created
% using makeMaskMovie.m and returns status = true if so, and status = false
% if not.
% 
% Hunter Elliott, 10/2009
% 


status = false;

if isfield(movieData,'movies') && isfield(movieData.movies,'maskMovie') ...
        && isfield(movieData.movies.maskMovie,'status') && movieData.movies.maskMovie.status == 1 ...
        && isfield(movieData.movies.maskMovie,'fileName') && ...
        exist([movieData.analysisDirectory filesep movieData.movies.maskMovie.fileName],'file')
    status = true;
    
end