function newPath = relocatePath(oldPath,oldRootDir,newRootDir)
% RELOCATEPATH relocates a path to a new location accounting for OS changes
% 
% newPath = relocatePath(oldPath,oldRootDir,newRootDir)
%
% Input:
% 
%   oldpath - The path(s) to be relocated. Works with strings, cell arrays 
%   or structure arrays
% 
%   oldrootdir - A string containing the root directory of the path which
%   will be substituted by this function. Can be any part of the
%   oldpath.
% 
%   newrootdir - A string containing the new root directory (belonging or
%   not to the same OS).
% 
% Output: 
%
%   newpath - Depending on the type of input, a string containing the name of
%   the relocated path , a structure array where all path fields have been 
%   relocated or a cell array where all valid paths have been relocated 
%
% See also: getRelocationDirs, getFilesep

% Sebastien Besson, 03/2011
%

% Check argument number and type
ip = inputParser;
ip.addRequired('oldPath')
ip.addRequired('oldRootDir',@ischar);
ip.addRequired('newRootDir',@ischar);
ip.parse(oldPath,oldRootDir,newRootDir);

% Return the input by default (no relocation)
newPath=oldPath;
if (isempty(oldRootDir) && isempty(newRootDir)), return; end

% Call function recursively if input is structure array or cell array
if isstruct(oldPath)    
    newPath = arrayfun(@(s) structfun(@(x) relocatePath(x,oldRootDir,newRootDir),...
        s,'UniformOutput',false),oldPath);
    return
elseif iscell(oldPath)
    newPath=cellfun(@(x) relocatePath(x,oldRootDir,newRootDir),oldPath,...
        'UniformOutput',false);
    return
end
if ~ischar(oldPath),return; end
% Check the old root directory is contained within the old path
nElements = min(numel(oldPath),numel(oldRootDir));
if isempty(oldRootDir) && ~strcmp(oldPath(1:nElements),oldRootDir), return; end %changes made to account for empty root directory -Sangyoon Han 160601


% Get file separators of old and new root directories as regular
% expressions
oldFilesep=getFilesep(oldRootDir);
newFilesep=getFilesep(newRootDir);

% Remove ending separators in the paths
oldPath=regexprep(oldPath,[oldFilesep '$'],'');
oldRootDir=regexprep(oldRootDir,[oldFilesep '$'],'');
newRootDir=regexprep(newRootDir,[newFilesep '$'],'');
% Generate the new path and replace the wrong file separators
if isempty(oldRootDir)
    % In the case of mount relocation from /mnt to /home/xxx/mnt
    newPath = [newRootDir oldPath];
else
    newPath=regexprep(oldPath,regexptranslate('escape',oldRootDir),regexptranslate('escape',newRootDir));
end
newPath=regexprep(newPath,oldFilesep,newFilesep);

end