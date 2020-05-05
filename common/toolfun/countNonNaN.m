function [ count ] = countNonNaN( M, dim )
%countNonNaN Count the number of non-NaN values along a dimension
%
% INPUT
% M - a N-dimensional matrix
% dim - dimension along which to count
%
% OUTPUT
% count - the number of non-NaN values along dimension dim
%
% See also isfinite

    if(nargin < 2)
        dim = 1;
    end
    count = size(M,dim) - sum(isnan(M),dim);
end

