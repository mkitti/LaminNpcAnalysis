function s = rReplace(s,findString,replaceString)

% s = rStructReplace(s,findString,replaceString)
% 
% Recursively finds and replaces the string findString with the string
% replaceString in the input s. If the input is a structure, all fields and
% sub-fields will undergo replacement. If the input does not contain
% findString, or is not a string, nothing will be done.
% 
% Input:
% 
%   s - The structure or string to replace strings in. If s is a structure,
%       every character string field AND sub-field will have every instance
%       of findString replaced by replaceString. If it is a string,
%       characters matching findString will be replaced by replaceString. 
% 
%   findString - The string (or regular expression) to find and replace
% 
%   replaceString - The string that findString will be replaced with.
% 
% 
% Output: 
%
%   s - The new structure/string with the replaced strings
%
% Hunter Elliott, 10/2009
%

if nargin < 3 || isempty(findString) || isempty(replaceString)
    
    error('Three non-empty inputs required!')
    
end

if ~ischar(findString) || ~ischar(replaceString)
    error('Inputs 2 and 3 must be character strings!')
end

if isstruct(s)    
    %Call this function on each field
    nS = length(s); %In the case that a field is actually a structure array.
    for i = 1:nS
        s(i) = structfun(@(x)(rReplace(x,findString,replaceString)),s(i),'UniformOutput',false);
    end
elseif iscell(s)
    s = cellfun(@(x)(rReplace(x,findString,replaceString)),s,'UniformOutput',false);
elseif ischar(s)
    s = regexprep(s,findString,replaceString);
end