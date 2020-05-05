function M = makeMovie(varargin)
%makeMovie : Create a movie of specified format from the image files in a
%            given dirctory.
%
% SYNOPSIS :
%    makeMovie(firstImgFile,format,outFileName,para,value,...)
%    M = makeMovie(firstImgFile,format,outFileName,para,value,...)
%
% INPUT :
%    firstImgFile : A string that specifies the name of the first image file
%       in the directory of image files.
%    format : A string that specifies the format of the movie you want to
%       make. Accepted formats are
%          'avi' (or 'AVI') : AVI movies.
%          'mov' (or 'MOV') : QuickTime movies.
%       Pass [] for the default movie format, 'avi'.
%    outFileName : A string that speicifies the name of the output movie file.
%
%    Some optional parameters can also be given to control how the movie is 
%    made.
%       FPS : Frame rate in terms of frames per second.
%
% OUTPUT :
%    M : A MATLAB movie can also be output.
%
% AUTHOR : Lin Ji, Mar. 11, 2004

if nargin < 3
   error('The first three arguments have to be given. See help makeMovie.');
end

if ~ischar(varargin{1})
   error('The first argument should be a string. See help makeMovie.');
else
   firstImgFile = varargin{1};
end

if isempty(varargin{2})
   format = 'avi';
elseif ~ischar(varargin{2}) | ...
   (strcmp(varargin{2},'mov') == 0 & strcmp(varargin{2},'MOV') == 0 & ...
   strcmp(varargin{2},'avi') == 0 & strcmp(varargin{2},'AVI') == 0)
   error('The second argument is not correctly defined. See help makeMovie.');
else
   format = varargin{2};
end

if ~ischar(varargin{3})
   error('The third argument should be a string. See help makeMovie.');
else
   outFileName = varargin{3};
end

fps = 10; %Default frame rate.

if nargin > 3
   if rem(nargin-3,2) ~= 0
      error('The parameters and values should appear in pair.');
   else
      for k = 4:2:nargin
         switch varargin{k}
         case 'FPS'
            fps = varargin{k+1};
         otherwise
            error('One of the optional parameters is not recognized.');
         end
      end
   end
end

%Get the list of image files. 
imgFile = getFileStackNames(firstImgFile);

%Get the position of the current figure which will set the size of each frame.
pos = get(gcf,'Position');
h   = figure(gcf); hold off;
set(h,'Position',pos);

if strcmp(format,'mov') == 1 | strcmp(format,'MOV')
   outFileName = [outFileName '.mov'];
   MakeQTMovie('start',outFileName);
   MakeQTMovie('framerate',fps);
end

for k = 1:length(imgFile)
   img = imread(imgFile{k});
   imshow(img,[]);
   set(h,'Position',pos);
   M(k) = getframe;

   if strcmp(format,'mov') == 1 | strcmp(format,'MOV')
      MakeQTMovie('addfigure');
   end
end

if strcmp(format,'mov') == 1 | strcmp(format,'MOV')
   MakeQTMovie('finish');
elseif strcmp(format,'avi') == 1 | strcmp(format,'AVI')
    v = VideoWriter(outFileName);
    open(v);
    writeVideo(v, M);
    close(v);
end
