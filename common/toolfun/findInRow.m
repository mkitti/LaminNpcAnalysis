function [ idx, idxNoNaN,nonNaNmap] = findInRow( X, varargin )
%findInRow Return the linear index of the first/last true element in each row
%
% INPUT
% X - a matrix with r rows and c columns
% n - see find
% direction - see find
%
% OUTPUT
% idx - either a cell array with dimensions r x 1 if the there are uneven
%              number of elements per row
%           OR a matrix with r x n if each row has the same number
%              of elements when the second argument 'n' is specified. If n
%              elements are not found, NaN will replace the element of idx
% idxNoNaN - if idx is a matrix this is an array of the non-NaN elements
% nonNaNMap - logical matrix of where the nonNaNs are
%
% See also find

% Mark Kittisopikul, Ph.D.
% Lab of Robert D. Goldman
% Northwestern University
% January 30th, 2018

idx = cell(size(X,1),1);
for r = 1:size(X,1)
    idx{r} = find(X(r,:),varargin{:});
    idx{r} = sub2ind(size(X),repmat(r,size(idx{r})),idx{r});
end

if(nargin > 1)
    n = varargin{1};
    for r = 1:size(X,1)
        idx{r}(end+1:n) = NaN;
    end
    idx = vertcat(idx{:});
    if(nargout > 1)
        nonNaNmap = ~isnan(idx);
        idxNoNaN = idx(nonNaNmap);
    end
end

% An alternative implementation is to use [r,c] = find(X) and analyze the row
% and column numbers. 