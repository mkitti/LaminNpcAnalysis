function [ B ] = squash( A )
%SQUASH Removes singleton dimensions like squeeze, but also turns rows into
%columns. This guarantees that a one dimensional array will become a
%column and that size(B,1) will not be 1 if A is not scalar. Unlike
%squeeze, this does affect 2-dimensional arrays.
%
% size(squeeze(shiftdim(1:3,6)))
% 
% ans =
% 
%      1     3
% size(squash(shiftdim(1:3,6)))
% 
% ans =
% 
%      3     1
%
% See also squeeze, shiftdim, reshape, joinColumns

% Mark Kittisopikul, June 2017

B = squeeze(A);
if(size(B,1) == 1)
    B = shiftdim(A,1);
end

end

