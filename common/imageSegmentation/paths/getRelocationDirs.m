function [oldRootDir,newRootDir,commonDir] = getRelocationDirs(oldPath,newPath)
% GETRELOCATIONDIRS compare paths and returns the differing root directories
% 
% Input:
% 
%   oldpath - A string containing the full old path
% 
%   oldrootdir - A string containing the full new path
% 
% Output: 
%
%   oldRootDir - A string containing the old working directory 
%
%   newRootDir - A string containing the new working directory
%
%   commonDir - A string containing the common architecture
%
% See also: relocatePath


% Sebastien Besson, July 2011
%

% Check input
ip = inputParser;
ip.addRequired('oldPath',@ischar);
ip.addRequired('newPath',@ischar);
ip.parse(oldPath,newPath);

%Remove ending file separators (for tree comparison)
oldPath = regexprep(oldPath,'([/\\])+$','');
newPath = regexprep(newPath,'([/\\])+$','');

% Split the path into tree components and compare trees backwards
[oldComponents, oldFilesepPos]=regexp(oldPath,'/|\','split');
[newComponents, newFilesepPos]=regexp(newPath,'/|\','split');
maxNumel = min(numel(oldComponents),numel(newComponents));
componentsCmp = strcmp(oldComponents(end:-1:end-maxNumel+1),...
    newComponents(end:-1:end-maxNumel+1));

% Append the last character of the paths (to handle the case where
oldFilesepPos = [oldFilesepPos numel(oldPath)];
newFilesepPos = [newFilesepPos numel(newPath)];

% Find first non-matching element
sizeCommonBranch=find(~componentsCmp,1);
oldRootDir=oldPath(1:oldFilesepPos(numel(oldComponents)-sizeCommonBranch+1));
newRootDir =newPath(1:newFilesepPos(numel(newComponents)-sizeCommonBranch+1));
commonDir = oldPath(oldFilesepPos(numel(oldComponents)-sizeCommonBranch+1)+1:end);