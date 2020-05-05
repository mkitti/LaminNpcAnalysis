function outDir = rmExtraFilesep(inDir,varargin)
%rmExtraFilesep: Remove extra filesep in a directory.
%
%   outDir = rmExtraFilesep(inDir);
%   outDir = rmExtraFilesep(inDir,'\');
%
%   'inDir' can be either a directory name or a cell array of directories.
%
% Author: Lin Ji, Oct, 2005.

fprintf(2,['Warning: ''' mfilename ''' is deprecated and should no longer be used.\n']);

%Default filesep.
filesepChar = filesep;

if nargin > 1
   filesepChar = varargin{1};
end

if ~iscell(inDir)
   outDir = {inDir};
else
   outDir = inDir;
end

for k = 1:length(outDir)
   filesepInd = findstr(filesepChar,outDir{k});
   if length(filesepInd) > 1
      extraFilesepInd = filesepInd(find(diff(filesepInd)==1));
      outDir{k}(extraFilesepInd) = '';
   end
end

if ~iscell(inDir)
   outDir = outDir{1};
end
