function getSubsequenceOfFiles(stepSize,outFName)
%getSubsequenceOfFiles: Get a subsequence of files every 'stepSize' from indexed
%                       files in 'inDir' and output it to 'outDir'.
%
% SYNOPSIS: getSubsequenceOfFiles(stepSize,outFName)
%
% INPUT:
%    stepSize: Get files every 'stepSize'.
%    outFName: The common prefix name for the output files. Pass [] to use the
%              same name as 'inFName'.
%
% Version: MATLAB Version 7.0.4.352 (R14) Service Pack 2.
% OS     : Linux.
%
% Author: Lin Ji, Dec. 20, 2005.

[firstFileName inDir filterIndex] = uigetfile('*.*','Pick the first file');
if isequal(firstFileName,0) || isequal(inDir,0)
   disp('User pressed cancel. No file is selected.');
   return;
end

[path,inFName,no,ext] = getFilenameBody(firstFileName);
firstFileIndex = str2num(no);

if isempty(outFName)
   outFName = inFName;
end
[filelist,index] = getNamedFiles(inDir,inFName);
selIndex = find(index>=firstFileIndex);
index    = index(selIndex);
filelist = filelist(selIndex);

numTotalFiles  = length(index);
subSequence    = [1:stepSize:numTotalFiles];
subIndex       = index(subSequence);
numSubseqFiles = length(subSequence);
indexForm      = sprintf('%%.%dd',length(num2str(numTotalFiles)));

parentDir = [inDir filesep '..'];
outDir = uigetdir(parentDir,'Select output directory');

if isequal(outDir,0)
   disp('User pressed cancel. No output directory is selected.');
   return;
end

startTime = cputime;
backStr   = '';
fprintf(1,'Processing: ');
for jj = 1:numSubseqFiles
   for ii = 1:length(backStr)
      fprintf(1,'\b');
   end
   backStr = sprintf('%d/%d ... ',jj,numSubseqFiles);
   fprintf(1,backStr);
   
   fileNo    = subSequence(jj);
   fileIndex = subIndex(jj);
   
   inFileName  = [inDir filesep filelist{fileNo}];
   outFileName = [outDir filesep outFName sprintf(indexForm,fileIndex) ext];
   [success,msgID] = copyfile(inFileName,outFileName);
end
fprintf(1,'Done in %5.3f sec.\n',cputime-startTime);
