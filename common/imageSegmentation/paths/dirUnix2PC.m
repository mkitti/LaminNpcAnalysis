function outDir = dirUnix2PC(inDir,winDrive,varargin)
%dirUnix2PC: Convert image directories from Unix format to PC format.
%
% SYNOPSIS:
%    outDir = dirUnix2PC(inDir,winDrive)
%    outDir = dirUnix2PC(inDir,winDrive,unixMntDrive)
%
% INPUT:
%    inDir        : Image directories in windows (PC) format. It can be a 
%                   cell array of directories. But, the directory has to 
%                   be a full path.
%    winDrive     : The disk drive letter for the image directory in PC format.
%                   It can be a cell array. In this case, the length has to
%                   match 'inDir' cell array.
%    unixMntDrive : An optional parameter (a string) that specifies the name of 
%                   the mounted disk drive in unix based platform. For example, 
%                   in traditional unix or linux, it is '/' or '/mnt' followed by a
%                   name. But in Max OS-X, it could be '/Volumes' followed by
%                   a name.
%
% Note: if 'unixMntDrive' is not specified, the program will automatically
% extract the drive name from 'inDir' according to conventional rule.
% 
% See also: dirPC2Unix.
% Author: Lin Ji, Mar, 2005.

fprintf(2,['Warning: ''' mfilename ''' is deprecated and should no longer be used.\n']);

%Default parameter:
unixMntDrive = {};

%Conventional mount root for auto detection of mounted drive name.
unixMntRoot = {'/mnt/', ...
               '/Volumes/'};

if ~iscell(inDir)
   outDir = {inDir};
else
   outDir = inDir;
end

if nargin > 2
   unixMntDrive = varargin{1};

   unixMntDrive = rmExtraFilesep(unixMntDrive,'/');
end

winDriveList = cell(size(outDir));
if ~iscell(winDrive)
   for k = 1:length(outDir)
      winDriveList{k} = winDrive;
   end
elseif length(winDrive) == 1
   for k = 1:length(outDir)
      winDriveList{k} = winDrive{1};
   end
else
   winDriveList = winDrive;
end

for k = 1:length(winDriveList)
   colonInd = findstr(':',winDriveList{k});
   if isempty(colonInd)
      winDriveList{k} = [winDriveList{k} ':'];
   end
   winDriveList{k} = [winDriveList{k} '\'];
end

%Make sure there is only one '/' as filesep in 'outDir{k}'.
outDir = rmExtraFilesep(outDir,'/');

if isempty(unixMntDrive)
   for k = 1:length(outDir)
      %Make sure the end of 'outDir{k}' is '/'.
      if ~strcmp(outDir{k}(end),'/')
         outDir{k}(end+1) = '/';
      end

      %Auto detect the name of mounted unix drive.
      mntInd = [];
      j = 1;
      while j <= length(unixMntRoot) & isempty(mntInd)
         mntInd = findstr(unixMntRoot{j},outDir{k});
         j = j+1;
      end
      if ~isempty(mntInd) && mntInd(1) == 1
         %Remove 'unixMntRoot'.
         outDir{k}(1:length(unixMntRoot{j-1})) = '';
      end

      %Remove extra '/' in the beginning of 'outDir{k}'.
      if strcmp(outDir{k}(1),'/')
         outDir{k}(1) = '';
      end

      %Then, we can remove the unix drive name.
      while ~isempty(outDir{k}) & ~strcmp(outDir{k}(1),'/')
         outDir{k}(1) = '';
      end
   end
else
   unixMntDriveList = cell(size(outDir));
   if ~iscell(unixMntDrive)
      for k = 1:length(outDir)
         unixMntDriveList{k} = unixMntDrive;
      end
   elseif length(unixMntDrive) == 1
      for k = 1:length(outDir)
         unixMntDriveList{k} = unixMntDrive{1};
      end
   else
      unixMntDriveList = unixMntDrive;
   end

   for k = 1:length(outDir)
      %Make sure the end of 'outDir{k}' is '/'.
      if ~strcmp(outDir{k}(end),'/')
         outDir{k}(end+1) = '/';
      end

      if isempty(unixMntDriveList{k}) || ~strcmp(unixMntDriveList{k}(1),'/')
         outDir = {};
         return;
      end

      %Make sure the end of 'unixMntDrive' is '/'.
      if ~strcmp(unixMntDriveList{k}(end),'/')
         unixMntDriveList{k}(end+1) = '/';
      end

      %Check if 'unixMntDrive' is the head string of 'outDir{k}'.
      mntInd = findstr(unixMntDriveList{k},outDir{k});
      if isempty(mntInd) || mntInd(1) ~= 1
         outDir = {};
         return;
      else
         outDir{k}(1:length(unixMntDriveList{k})) = '';
      end
   end
end

for k = 1:length(outDir)
   %Remove extra '/' in front of 'outDir{k}'.
   if strcmp(outDir{k}(1),'/')
      outDir{k}(1) = '';
   end

   fileSepInd = findstr('/',outDir{k});
   outDir{k}(fileSepInd) = '\';

   outDir{k} = [winDriveList{k} outDir{k}];
   
   %HLE - got rid of trailing fileseperator introduced above
    if strcmp(outDir{k}(end),'\')
        outDir{k} = outDir{k}(1:end-1);
    end
end



if ~iscell(inDir)
   outDir = outDir{1};
end
