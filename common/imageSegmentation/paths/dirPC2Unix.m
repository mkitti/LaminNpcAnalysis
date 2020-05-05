function outDir = dirPC2Unix(inDir,unixDrive)
%dirPC2Unix: Convert image directories from PC format to Unix format.
%
% SYNOPSIS:
%    outDir = dirPC2Unix(inDir,unixDrive)
%
% INPUT:
%    inDir     : Image directories in PC format. It can be a cell array.
%    unixDrive : The name of the mounted disk drive in Unix. It can be a cell
%                array. In this case, the length has to match 'inDir' cell
%                array.
%
% See also: dirUnix2PC.
% Author: Lin Ji, Mar, 2005

fprintf(2,['Warning: ''' mfilename ''' is deprecated and should no longer be used.\n']);

if ~iscell(inDir)
   outDir = {inDir};
else
   outDir = inDir;
end

unixDriveList = cell(size(outDir));

if ~iscell(unixDrive)
   for k = 1:length(outDir)
      unixDriveList{k} = unixDrive;
   end
elseif length(unixDrive) == 1
   for k = 1:length(outDir)
      unixDriveList{k} = unixDrive{1};
   end
else
   unixDriveList = unixDrive;
end

for k = 1:length(unixDriveList)
   unixDriveList{k} = rmExtraFilesep(unixDriveList{k});

   if ~strcmp(unixDriveList{k}(1),'/')
      unixDriveList{k} = ['/' unixDriveList{k}];
   end

   %Remove extra '/' from the end of 'unixDrive'.
   if strcmp(unixDriveList{k}(end),'/')
      unixDriveList{k}(end) = '';
   end
end


for k = 1:length(outDir)
   colonInd = findstr(':',outDir{k});
   outDir{k}(1:colonInd(1)) = '';

   fileSepInd = findstr('\',outDir{k});
   outDir{k}(fileSepInd) = '/';

   outDir{k} = [unixDriveList{k} '/' outDir{k}];

   %Remove extra filesep.
   outDir{k} = rmExtraFilesep(outDir{k},'/');
end

if ~iscell(inDir)
   outDir = outDir{1};
end
