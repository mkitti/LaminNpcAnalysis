function varargout = movieArrayMontage(movieArray,varargin)

% movieArrayMontage(movieArray)
%
% h = movieArrayMontage(movieArray,'OptionName',optionValue)
%
% Makes a big figure containing an image from each movie in the movieArray
% as a sub-plot of the figure. Any additional arguments (as
% OptionName/value pairs) will be passed to the viewing function,
% imageViewer.m. See it's help for descriptions of these options.
%
% 
% Input:
% 
%   movieArray - A cell-array of movieData structures. The moviedata structures
%   should be formatted as created by setupMovieData.m
% 
%   'OptionName',optionValue - A string with an option name followed by the
%   value for that option. These options will be passed to the function
%   imageViewer - see it's help section for details.
% 
% Output:
% 
%   h - The handle of the figure the images were displayed on.
% 
% Hunter Elliott
% 
% 3/2009
%

if nargin < 1 || isempty(movieArray)
    error('Come on, you have to input something!')
end

nMovies = length(movieArray(:));

%Make the figure
fHan = figure;

%Return the handle if requested
if nargout > 0
    varargout{1} = fHan;
end

%Determine the size of the grid of images
gridSize = ceil(sqrt(nMovies));

%Loop through the movies and display an image from each one.
for j = 1:nMovies
    
    subplot(gridSize,gridSize,j);%Switch to current plot
    axHandle = gca; %Get handle for current axes;
    try
        imageViewer(movieArray(j),varargin{:},'AxesHandle',axHandle) %Show the image
        title(num2str(j));
    catch errMess
        text(0,0,'Problem with movie channel/frame...','color','w')
        text(0,15,errMess.message,'color','w')
    end
end