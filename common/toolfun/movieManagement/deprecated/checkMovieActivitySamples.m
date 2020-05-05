function okay = checkMovieActivitySamples(movieData)

%{
okay = checkMovieActivitySamples(movieData)

Returns true if the input movie's movieData indicates it's activity has successfully been sampled on at least one channel.

Hunter Elliott, 4/2009

%}


%TEMP - check that channel is specified!!! HLE

okay = false;

if isfield(movieData,'activity') && isfield(movieData.activity,'status') && movieData.activity.status == 1 ...
        && isfield(movieData.activity,'fileName') && isfield(movieData.activity,'directory') ...
        && exist([movieData.activity.directory filesep movieData.activity.fileName],'file')
    
    okay = true;
end
        