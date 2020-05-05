function [fileList, index] = getNamedFiles(srchDir,fName)
% getNamedFiles: Get files with a common prefix name.
%
% SYNOPSIS
%    [fileList,index] = getNamedFiles(srchDir,fName);
%
% INPUT:
%    srchDir: Directory where you want to search for the files.
%    fName  : The common prefix file name.
%
% OUTPUT:
%    fileList: A cell array of found files.
%    index   : The index (number suffix) of the files.
%
% AUTHOR: Lin Ji.
% DATE  : July 21, 2006

if ~isdir(srchDir)
   fileList = {};
   index    = [];
   return;
end
dirList  = dir(srchDir);
allFileList = {dirList(find([dirList.isdir] == 0)).name};
fileList = allFileList(strmatch(fName,allFileList));

%Get the index of the available mask files.
index = zeros(size(fileList));
for k = 1:length(fileList)
   [path,body,no,ext] = getFilenameBody(fileList{k});
   if isempty(no)
      index(k) = NaN;
   else
      index(k) = str2num(no);
   end
end

%Get rid of 'NaN'.
nanInd = find(isnan(index));
index(nanInd)    = [];
fileList(nanInd) = [];

[index,sortedI] = sort(index);
fileList = fileList(sortedI);
