function [ out ] = isProcessOrMovieList( x )
%isProcessOrMovieList True if input is a Process or MovieList instance

out = isProcessOrMovieObject(x, 'MovieList');

end

