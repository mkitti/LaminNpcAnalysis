function [polyScanOut,polygonIn] = polygonScanMovieChannels(movieData,polygonIn,iFrame,viewChan,showPlots)
% 
%  [polyScanOut,polygonIn] = polygonScanMovieChannels(movieData,polygonIn)
% 
%  Performs a polygon/line scan on each channel of the input movieData.
%  If no polygon is input, the user is asked to click on the image to create
%  one.
%       Warning: If the polygon intersects itself, weird shit is going to happen.
% 
%     
% Input:
% 
% 
%   polygonIn   -   Optional. The polygon / line describing the scan to
%                          perform. If left empty, the user enters one
%                          interactively.
%
% 
%  iFrame          -   The frame number(s) of the image(s) to scan.
%                           If a vector of integers is input, all frames
%                           will be scanned (a.k.a. kymograph)
%                            Optional. Defaults to 1st frame only.
%
%   viewChan   -   The channel # to view when performing linescan.
%                           Defaults to 1
%
%   showPlots   -   If true, a plot of the resulting scan is displayed.
%
%
%
%   Output:
% 
%   polyScanOut     -   This is a Mx2 array containing the values of each
%                                 pixel along the line (2nd column), and
%                                 its relative position along the length of
%                                 each side of the polygon (1st column).
%                                 Points on side 1 will go from 1.000 to
%                                 1.999, points on side to will go from
%                                 2.000 to 2.999 and so on. This means if
%                                 the different sides are different lengths
%                                 you need to be carefu comparing theml!
% 
% 
% 
%  polygonIn        -    This is the 2xM vector of the vertex positions of
%                               the polygon used to scan the image.
% 
% 
% 
% 



movieData = setupMovieData(movieData);

if nargin < 2
    polygonIn = [];
end

if nargin < 3 || isempty(iFrame)
    iFrame = 1;
end

if nargin < 4 || isempty(viewChan)
    viewChan = 1;
end

if nargin < 5 || isempty(showPlots)
    showPlots = true;
end

%Get number of channels
nChan = length(movieData.channelDirectory);

%If the polygon wasn't input, allow the user to create it

currIm = imageLoader(movieData,movieData.channelDirectory{viewChan},iFrame(1));%Load the image for the channel selected for viewing
[tmpScan,polygonIn] = polygonScan(currIm,polygonIn,false);

nFrames = length(iFrame);
nPts = size(tmpScan,1);

%Init mem for scan results
polyScanOut = nan(nPts,nChan+1,nFrames);
polyScanOut(:,1) = tmpScan(:,1);


if nFrames > 2
    h = waitbar(0,'Please wait, scanning frames....');
end
    
    
%Scan each frame
for mFrame = 1:nFrames
    %Scan each channel
    for iChan = 1:nChan

        %Load the image for this channel
        currIm = imageLoader(movieData,movieData.channelDirectory{iChan},iFrame(mFrame));

        [tmpScan,polygonIn] = polygonScan(currIm,polygonIn,false);
        
        polyScanOut(:,1 + iChan,mFrame) = tmpScan(:,2);        

    end
    
    if nFrames > 2
        waitbar(mFrame/nFrames,h);
    end
    
end

if showPlots
    
    if nFrames < 2
        figure
        hold on

        for j = 2:nChan+1
            plot(polyScanOut(:,1),polyScanOut(:,j) ,'color',rand(1,3))        
        end    
        xlabel('Position along polygon edge(s)')
        ylabel('Image Intensity')
        
        legend(movieData.channelDirectory);    

    else
        figure
        for j = 2:nChan+1
            surf(squeeze(polyScanOut(:,j,:)),rand(1)*ones(size(squeeze(polyScanOut(:,j,:)))),'FaceAlpha',.5,'EdgeAlpha',.3)
            hold on
        end
        light,light
        
    end
   
end

if nFrames > 2 && ishandle(h)
    close(h);
end