function hScaleBar = plotTimeStamp(time, varargin)
%plotTimeStamp(time, varargin) adds a time stamp to a figure.
%
% Inputs:  
%     time : width of the scale bar, in x-axis units.
%     
%     varargin : optional inputs, always in name/value pairs:
%           'Handle'   : handle to the axis where to plot the timeStamp
%           'Location' : {'NorthEast', 'SouthEast', 'SouthWest', 'NorthWest'}
%           'FontName' : string
%           'FontSize' : scalar 
%           'FontUnits': string 
%           'Color'    : 3 element vector giving the color of the time stamp
%
% Ouput: 
%     hScalebar : handle to the text graphic object
%
% Example: plotTimeStamp('00:00:20:0000', 'Location', 'SouthEast');
%
% Note: there is a bug in '-depsc2' as of Matlab2010b, which misprints patches.
%       When printing, use 'depsc' instead.

% Sebastien Besson, March 2012
% Adapted from plotScaleBar.m

% Intialize inputParser
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('time', @ischar);
ip.addParameter('Handle', gca, @ishandle)
ip.addParameter('Location', 'southwest', @(x) any(strcmpi(x, {'northeast', 'southeast', 'southwest', 'northwest'})));
ip.addParameter('FontName', 'Helvetica', @ischar);
ip.addParameter('FontSize', .02, @isscalar);
ip.addParameter('FontUnits', 'normalized', @ischar);
ip.addParameter('Color', [1 1 1], @(x) isvector(x) && numel(x)==3);

% Parse input
ip.parse(time, varargin{:});
fontName = ip.Results.FontName;
fontSize = ip.Results.FontSize;
fontUnits = ip.Results.FontUnits;
color = ip.Results.Color;

location = lower(ip.Results.Location);

% Get axis limits
XLim = get(ip.Results.Handle, 'XLim');
YLim = get(ip.Results.Handle, 'YLim');
lx = diff(XLim);
ly = diff(YLim);

dx = ly/30; % distance from border

% Construct text graphic object
textProps = {'Color', color, 'FontUnits', fontUnits,...
    'FontName', fontName, 'FontSize', fontSize,...
    'VerticalAlignment', 'Top',...
    'HorizontalAlignment', 'left'};
hScaleBar = text(0, 0, time,textProps{:});

% Get dimensions of time stamp bounding box
extent = get(hScaleBar, 'extent'); % units: pixels
textHeight = 1.2*extent(4);
textWidth = extent(3);

hold(ip.Results.Handle, 'on');
set(gcf, 'InvertHardcopy', 'off');

if ~isempty(strfind(location, 'north'))
    y0 = dx;
else
    y0 = ly-textHeight;
end
if ~isempty(strfind(location, 'east'))
    x0 = lx-textWidth-dx;
else
    x0 = dx;
end

x0 = x0+XLim(1);
y0 = y0+YLim(1);

set(hScaleBar,'Position',[x0 y0]);