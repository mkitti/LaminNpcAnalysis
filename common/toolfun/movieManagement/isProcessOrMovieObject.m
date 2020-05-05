function [ out ] = isProcessOrMovieObject( x , className)
%isProcessOrMovieObject True if x is a Process or MovieObject of type
%className

if(nargin < 2)
    className = 'MovieObject';
end

out = isa(x,'Process') && isa(x.getOwner(),className) || isa(x,className);

end

