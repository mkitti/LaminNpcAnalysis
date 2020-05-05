function [ A ] = nanreplace( A, replacement )
%nanreplace Replace NaNs with a replacement
%
% INPUT
% A - array containing NaNs
% replacement - (optional) Number put in place of NaNs
%
% OUTPUT
% A - array with NaNs replaced
%
% Comment: Mainly added for lambda calculus one-liners
%
% Author:
% Mark Kittisopikul, Ph.D.
% Goldman Lab
% Northwestern University
%
% August 2019

if(nargin < 2)
    replacement = 0;
end

A(isnan(A)) = replacement;

end

