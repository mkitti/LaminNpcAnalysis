function varargout = showMovieTimeline(movieData,nFrames,iChan,figureHandle,varargin)
%SHOWMOVIETIMELINE displays several images from a movie side-by-side
% 
% figureHandle = showMovieTimeline(movieData)
% 
% figureHandle = showMovieTimeline(movieData,nFrames,iChan,figHan)
%
% figureHandle = showMovieTimeline(movieData,nFrames,iChan,figHan,'OptionName',optionValues)
%
% This function displays several frames from selected channel(s) of the
% input movie side-by-side as sub-plots of the same figure, using
% imageViewer.m.
% 
% Input:
%          
%     nFrames - The number of frames to display from the movie. Optional,
%     default is 3.
%     
%     iChan - The indices of the channel(s) to display a timeline for.
%     Optional, default is 1.
%
%     figureHandle - The handle of the figure to show the frames on.
%     Optional, if not input, a new figure is created.
%
%     'OptionName',optionValue - Additional options to pass to
%     imageViewer.m. See the imageViewer.m documentation for details.
%     
% Output:
% 
%     figureHandle - The handle of the figure which the frames were plotted
%     on.
%     
%     
% Hunter Elliott, 10/2009
% Revamped 6/2010
%


if nargin < 1 || isempty(movieData)
    error('Must input movieData!')
end

if ~isa(movieData,'MovieData')
    error('The first input must be a valid MovieData object!')
end

if nargin < 2 || isempty(nFrames)
    nFrames = 3;   
end

if nargin < 3 || isempty(iChan)
    iChan = 1;
end

if nargin < 4 || isempty(figureHandle)    
    figureHandle = fsFigure(.75);
else
    figure(figureHandle)
    clf
    hold on
end

nChan = length(iChan);
iFrames = floor(linspace(1,movieData.nFrames_,nFrames));

if nChan <= 3
    %if 3 or fewer channels, we can overlay them
    for j = 1:nFrames
        subplot(1,nFrames,j)
        if ~isempty(varargin)
            imageViewer(movieData,'ChannelIndex',iChan,'Frame',iFrames(j),'AxesHandle',gca,varargin{:})
        else
            imageViewer(movieData,'ChannelIndex',iChan,'Frame',iFrames(j),'AxesHandle',gca)
        end

    end
else    
    for j = 1:nFrames
        for k = 1:nChan
            subplot(nChan,nFrames,(k-1)*nFrames+j)
            if ~isempty(varargin)
                imageViewer(movieData,'ChannelIndex',iChan(k),'Frame',iFrames(j),'AxesHandle',gca,varargin{:})
            else
                imageViewer(movieData,'ChannelIndex',iChan(k),'Frame',iFrames(j),'AxesHandle',gca)
            end
        end
    end
end
if nargout > 0
    varargout{1} = figureHandle;
end