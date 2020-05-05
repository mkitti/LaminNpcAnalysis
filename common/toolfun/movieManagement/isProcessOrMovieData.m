function [ out ] = isProcessOrMovieData( x )
%isProcessOrMovieData True if input is a Process or MovieData instance

out = isProcessOrMovieObject(x, 'MovieData');

end

