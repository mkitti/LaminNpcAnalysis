function [matches,matchingMovieArray] = findMoviesInClass(movieArray,className,category)
% 
%  [matches,matchingMovieArray] =
%  findMoviesInClass(movieArray,className,category)
% 
%  This function finds movies within the input movieArray have been
%  classified within the classification "className" as being in the
%  category "category"
%
%  Movies can be classified using the function manualClassifyMovie.m
%
% Input:
% 
%     movieArray - cell array of structures to search.
%     
%     className - name of the classification type. 
%     
%     category - The category within the classification that the movies
%                should belong to.
% Output:
% 
%     matches - A vector specifying which movies are in the requested
%               category. 1 means they are in the category, 0 means they
%               are in a different category, and -1 means the movie has not
%               been classified using the classification className.
%     
% 
% Hunter Elliott, 10/2009
% 


%% ------- Input ------- %%

if nargin < 3
    category = '';
end

if nargin < 2 || isempty(movieArray) || isempty(className)
    error('Must input a cell array of movieDatas and a classification name!')
end

if ~iscell(movieArray) || length(movieArray) < 1
    error('Input movieArray must be a cell array of movieDatas of length >= 1 !!!')
end

if ~ischar(className) || ~ischar(category)
    error('Inputs className and category must be character strings!')
end


%% ------- Init -------%%

nMovies = length(movieArray);

matches = -1*ones(nMovies,1);

matchingMovieArray = cell(nMovies,1);


%% ----- Find Matches ----- %%

iHasField = find(cellfun(@(x)(isfield(x,'classification') && isfield(x.classification,className)),movieArray));

iInCat = cellfun(@(x)(any(strcmp(x.classification.(className),category))),movieArray(iHasField));

matches(iHasField) = 0;

matches(iHasField(iInCat)) = 1;

matchingMovieArray = movieArray(matches == 1);


