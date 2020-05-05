function regexpFilesep=getFilesep(path)
% GETFILESEP returns the file separator associated with a given path as a
% regular expression
%
% 
% INPUT
%   path - A string containing the path which file separator should be
%   found
%
% OUTPUT 
%   regexpFilesep - the file separator formatted as a regular expression
%   (to be used in regexpfunction )
%

% Sebastien Besson, July 2011
%
   
% Find all file separators in the path name
pathSep=unique(regexp(path,'/|\','match'));
if numel(pathSep)>1, error(['Error!! OS conflict in path: ' path]); end

%Deal with special cases (no file separator found)
if isempty(pathSep)
    % Linux path may be root path '' or home directory path '~'
    isLinux = @(x) logical(isempty(x) || strcmp(x,'~'));
    % Windows path may be a drive letter with or without colon e.g. C:, H
    isWindow = @(x) logical(~isempty(regexp(x,'^[A-Z]:?$','match')));
    
    pathSep = char(isLinux(path)*'/'+isWindow(path)*'\');
    if strcmp(pathSep,char(0)),
        error(['Error!! Cannot identify the nature of path: ' path]);
    end
else pathSep=pathSep{1};
end

% Return the file separator as a regular expression
regexpFilesep=regexptranslate('escape',pathSep);
end