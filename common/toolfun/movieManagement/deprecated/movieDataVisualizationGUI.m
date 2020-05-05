function varargout = movieDataVisualizationGUI(varargin)
% MOVIEDATAVISUALIZATIONGUI M-file for movieDataVisualizationGUI.fig
%      MOVIEDATAVISUALIZATIONGUI, by itself, creates a new MOVIEDATAVISUALIZATIONGUI or raises the existing
%      singleton*.
%
%      H = MOVIEDATAVISUALIZATIONGUI returns the handle to a new MOVIEDATAVISUALIZATIONGUI or the handle to
%      the existing singleton*.
%
%      MOVIEDATAVISUALIZATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVIEDATAVISUALIZATIONGUI.M with the given input arguments.
%
%      MOVIEDATAVISUALIZATIONGUI('Property','Value',...) creates a new MOVIEDATAVISUALIZATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before movieDataVisualizationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to movieDataVisualizationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help movieDataVisualizationGUI

% Last Modified by GUIDE v2.5 02-Jun-2011 08:56:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @movieDataVisualizationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @movieDataVisualizationGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before movieDataVisualizationGUI is made visible.
function movieDataVisualizationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% movieDataVisualizationGUI(movieData, process)

%     userData.MD - MovieData
%     userData.nFrames - number of frames
%     userData.iFrame - current frame
%     userData.cMap - current colormap
%     userData.colStr - RGB color string
%     userData.nChan - number of channels

%     userData.pixelProcess - cell array. Pool of pixel process. The first
%                             cell is empty, meaning original image is
%                             displayed
%     userData.overlayProcess - cell array. Pool of overlay process
    
%     userData.iPixel - index of current pixel process (non-empty)
%     userData.iPixelChan - the channel index that has valid result for pixel process
%     userData.iOverlay - index of current overlay process (Empty means no overlay.)
%     userData.iOverlayChan - the channel index that has valid result for overlay process

%     userData.rgbPixelChan - 1x3 array, channel index displayed in RGB for pixel process
%     userData.grayPixelChan - 1x1 array, channel index displayed in gray-scale image for pixel process
%     userData.grayOverlayChan - 1x1 array, channel index displayed in gray-scale for overlay process
%     userData.hImage - handle of image object
%     userData.hOverlay - handle of overlay object
%     userData.ini - initilization indicater. 

%     userData.hFigure
%     handles.rgbCheckbox - 1x3 array. Handles of rgb checkboxes
%     handles.rgbPopupmenu - 1x3 array. Handles of rgb popup menu
%     handles.pixelProcess - 1xn array. Handles of items under image menu
%     handles.overlayProcess - 1xn array. Handles of the items under overlay menu

set(handles.text_copyright, 'String', getLCCBCopyright());

userData = get(handles.figure1, 'UserData');
% Choose default command line output for movieDataVisualizationGUI
handles.output = hObject;

if nargin > 3
    
    assert( isa(varargin{1}, 'MovieData'), 'User-defined: The first input must be a MovieData object.')
    userData.MD = varargin{1};
    userData.nFrames = userData.MD.nFrames_;
    userData.iFrame = 1; % Default is to display the first frame
    userData.cMap = 'gray';
    userData.colStr = {'r','g','b'};
    userData.nChan = length(userData.MD.channels_);
    userData.hFigure = [];
    
    userData.iPixel = 1;
    userData.iPixelChan = 1:userData.nChan;
    userData.iOverlay = [];
    userData.iOverlayChan = [];
    
    userData.rgbPixelChan = zeros(1,3); 
    userData.grayPixelChan = 0;
    userData.grayOverlayChan = 0;
    userData.iFrame = 1;
    userData.hImage = [ ];
    userData.ini = 1;
    
    handles.rgbCheckbox = [handles.checkbox_red handles.checkbox_green handles.checkbox_blue];
    handles.rgbPopupmenu = [handles.popupmenu_red handles.popupmenu_green handles.popupmenu_blue];
    
    % Classify the processes
    [pixelProcess, overlayProcess] = processParse(userData.MD);
    
    % userData saves processes
    userData.pixelProcess = [{[]} pixelProcess];
    userData.overlayProcess = overlayProcess;
    
    % handle of overlay data
    userData.hOverlay = repmat({cell(1, userData.nChan)}, [1 length(overlayProcess)]);
    
    if isempty(pixelProcess) && isempty(overlayProcess)
       warndlg('There is no pixel or overlay data to be displayed in this movie data.'); 
    end
    
    % handles saves handles of submenu
    handles.pixelProcess = arrayfun(@(x)uimenu(handles.menu_image,...
        'Label',pixelProcess{x}.name_,'Callback',@submenu_image_Callback,...
        'UserData', x+1), 1:length(pixelProcess) );
    handles.pixelProcess = [handles.menu_image_raw handles.pixelProcess];
   
    if length(handles.pixelProcess) > 1
       set(handles.pixelProcess(2), 'Separator', 'on') % Add seperator
    end
    
    handles.overlayProcess = arrayfun(@(x)uimenu(handles.menu_overlay,'Label',...
        overlayProcess{x}.name_,'Callback',@submenu_overlay_Callback,...
        'UserData', x), 1:length(overlayProcess) );
    guidata(hObject, handles)
    
    % If input process
    if nargin > 4 
        
        index1 = find( arrayfun(@(x)isequal(varargin{2}, userData.pixelProcess{x}), 1:length(userData.pixelProcess) ) );
        index2 = find( arrayfun(@(x)isequal(varargin{2}, userData.overlayProcess{x}), 1:length(userData.overlayProcess) ) );
        
        if ~isempty(index1) && ~isempty(index2)
            error('User-defined: processParse error.')
            
        elseif ~isempty(index1) && length(index1) == 1
            % pixel process
            userData.iPixel = index1;
            
        elseif ~isempty(index2) && length(index2) == 1
            % overlay process
            userData.iOverlay = index2;
            
        else
            error('User-defined: input process error.')
        end
        
    end
    
    % Set up iPixelChan and iOverlayChan

    set(handles.figure1, 'UserData', userData)
    submenu_image_Callback(handles.pixelProcess(userData.iPixel), [], handles)
    
    if ~isempty(userData.iOverlay)

        % Set up user data and GUi for overlay processes
        submenu_overlay_Callback(handles.overlayProcess(userData.iOverlay), [], handles)
    else
        set(handles.text_overlay, 'String', 'None')
    end
    
    userData = get(handles.figure1, 'UserData');
    
    
    % GUI set-up
    set(handles.edit_path, 'String', [userData.MD.movieDataPath_ userData.MD.movieDataFileName_]) 
    set(handles.edit_frame, 'String', num2str(userData.iFrame))
    set(handles.text_framenum, 'String', ['/ ' num2str(userData.nFrames)])
    if userData.nFrames <2
        set(handles.slider_frame, 'Enable', 'off')
    else
        set(handles.slider_frame, 'Min', 1, 'Max', userData.nFrames, 'Value', 1, 'SliderStep', [1/(userData.nFrames-1) 1] )
    end
    set(handles.text_gray, 'BackgroundColor', get(hObject, 'Color'))
    
    % If only one channel available to display, swich to single channel option
%     if length(userData.iPixelChan) == 1
        
%        set(handles.radiobutton_gray, 'Value', 1)
%        uipanel_display_SelectionChangeFcn(handles.radiobutton_gray, ...
%            struct('EventName', 'SelectionChanged', 'OldValue',handles.radiobutton_rgb,'NewValue',handles.radiobutton_gray))
%     end

    set(handles.uipanel_display, 'SelectionChangeFcn', @uipanel_display_SelectionChangeFcn);
    set(handles.uipanel_overlay, 'SelectionChangeFcn', @uipanel_overlay_SelectionChangeFcn);

end


set(handles.figure1,'UserData',userData)

drawingFigure(handles, 'pixel', 'on', 1:3)
drawingFigure(handles, 'overlay', 'on', 1:3)

userData = get(handles.figure1, 'UserData');
title(get(userData.hFigure, 'CurrentAxes'), [num2str(userData.iFrame) ' / ' num2str(userData.nFrames)])
userData.ini = 0;
set(handles.figure1,'UserData',userData)


function drawingFigure(handles, type, onoff, layer, varargin)

userData = get(handles.figure1, 'UserData');

% If no layer, assume gray-scale
if nargin < 4, layer = 1; end

if strcmp(onoff, 'on'), onoff = 1; else onoff = 0; end

% If the handle of the figure is invalid
if isempty(userData.hFigure) || ~ishandle(userData.hFigure)
    
   userData.hFigure = figure('Name', 'Display', 'NumberTitle', 'off');
   haxes = axes;
   set(userData.hFigure, 'CurrentAxes', haxes)
   set(handles.figure1, 'UserData', userData)
   
   
   if ~userData.ini
       
       userData.hImage = [];
       userData.hOverlay = repmat({cell(1, userData.nChan)}, [1 length(userData.overlayProcess)]);
       set(handles.figure1, 'UserData', userData)

       dispImage(userData.hFigure, handles, 'on', 1:3)  
       dispOverlay(userData.hFigure, handles, 'on', 1:3)
       
   
       userData = get(handles.figure1, 'UserData');
   end
   
end

switch lower(type)

    case 'pixel'
        dispImage(userData.hFigure, handles, onoff, layer)
        
    case 'overlay'
        dispOverlay(userData.hFigure, handles, onoff, layer, varargin{:})
        
    otherwise
        error('User-defined: Invalid input.')
end

colormapStr = get(handles.popupmenu_colormap, 'String');
colormap(get(userData.hFigure, 'CurrentAxes'), colormapStr{get(handles.popupmenu_colormap, 'Value')})



function dispImage(hfigure, handles, onoff, layer)

userData = get(handles.figure1, 'UserData');

% Determine if image is RGB
if get(handles.radiobutton_rgb, 'Value')
    isrgb = 1;
else 
    isrgb = 0;
    layer = 1;
end

% Determine if image is raw image
if userData.iPixel == 1
    israw = 1;
else
    israw = 0; 
end

if nargin < 3
    
    onoff = 1;
    if isrgb
        layer = 1:3;
    else
        layer = 1;
    end
end

if nargin < 4
   if isrgb
       layer = 1:3;
   end
   
elseif any(layer > 3)
    error('User-defined: layer should be smaller or equal to 3.')
end



if isrgb  % If RGB image

   if onoff  % If turn on RGB image
       if isempty(userData.hImage) || ~ishandle(userData.hImage) 
          
           currImage = zeros([userData.MD.imSize_ 3]);
       else
           currImage = get(userData.hImage, 'CData');
           
           if length(size(currImage)) < 3               
               currImage = zeros([userData.MD.imSize_ 3]);
           end
       end
       
       % Check if any channel index is 0

       currImage(:,:,logical(~userData.rgbPixelChan(layer))) = 0;
       layer = layer(logical(userData.rgbPixelChan(layer)));

       
       if israw
           %Use the raw data as the image directories

           for j = layer
                   
               imDirs = userData.MD.getChannelPaths(userData.rgbPixelChan(j)); 
               imNames = userData.MD.getImageFileNames(userData.rgbPixelChan(j)); 
               currImage(:,:,j) = mat2gray(imread([imDirs{1} filesep imNames{1}{userData.iFrame}]));  

           end           
       else
           
           for j = layer
               currImage(:,:,j) = mat2gray(userData.pixelProcess{userData.iPixel}.loadOutImage(userData.rgbPixelChan(j),userData.iFrame));  
           end
       end
       
       % Draw the image
       if isempty(userData.hImage) || ~ishandle(userData.hImage)

           figure(hfigure)
           userData.hImage = imshow(currImage, []); 
       else
           set(userData.hImage, 'CData', currImage, 'CDataMapping', 'direct');
       end       
       
   else  % If turn off RGB image
       if ~isempty(userData.hImage) && ishandle(userData.hImage)
           
           currImage = get(userData.hImage, 'CData');
           
           for j = layer
               currImage(:,:,j) = 0;         
           end
           set(userData.hImage, 'CData', currImage, 'CDataMapping', 'direct')
       end       
   end
    
else  % If gray scale image
    
    if onoff % If turn on gray scale image
       
        % If gray
       if ~userData.grayPixelChan
           error('User-defined: gray display channel index is 0. ')
       end
       
       if israw
           
            %Use the raw data as the image directories
            imDirs = userData.MD.getChannelPaths(userData.grayPixelChan); 
            imNames = userData.MD.getImageFileNames(userData.grayPixelChan); 
           
            currImage = mat2gray(imread([imDirs{1} filesep imNames{1}{userData.iFrame}]));  
%             currImage = imread([imDirs{1} filesep imNames{1}{userData.iFrame}]); 

       else
           
           currImage = mat2gray(userData.pixelProcess{userData.iPixel}.loadOutImage(userData.grayPixelChan, userData.iFrame));
%            currImage = userData.pixelProcess{userData.iPixel}.loadOutImage(userData.grayPixelChan, userData.iFrame);
       end
       
       % Draw the image
       if isempty(userData.hImage) || ~ishandle(userData.hImage)

           figure(hfigure)
           userData.hImage = imshow(currImage, []); 
       else

           set(userData.hImage, 'CData', currImage, 'CDataMapping', 'scaled');
       end 
       
    else  % If turn off gray scale image
        if ~isempty(userData.hImage) && ishandle(userData.hImage)

            currImage = get(userData.hImage, 'CData');
            currImage(:,:) = 0;
            set(userData.hImage, 'CData', currImage, 'CDataMapping', 'scaled')            
           
        end            
    end
    
end

set(handles.figure1, 'UserData', userData)



function dispOverlay(hfigure, handles, onoff, layer, varargin)

% If no layer input, assume it's rgb
if nargin < 4, layer = 1:3; end

userData = get(handles.figure1, 'UserData');

if ~isempty(userData.iOverlayChan)
    process = userData.overlayProcess{userData.iOverlay};
end

% Determine if image is RGB
if nargin < 5
    if get(handles.radiobutton_1, 'Value')
        isrgb = 1;

    else % gray overlay
        isrgb = 0;
        layer = 1;
    end
else
    if strcmp(varargin{1}, 'hideRGBoverlay')
        isrgb = 1; 
       
    elseif strcmp(varargin{1}, 'hideGRAYoverlay')
        isrgb = 0;
        layer = 1;
    end
    
end

figure(hfigure)
hold(get(hfigure, 'CurrentAxes'), 'on');

    
if isrgb
    layer = layer( arrayfun(@(x)any(userData.iOverlayChan == x),  userData.rgbPixelChan(layer)) );
        
elseif isempty(userData.iOverlay) % If no overlay selected, then skip drawing overlay
    layer = [];
end
        
if onoff  % Turn overlay on
        
        
    for j = layer
            
        if isrgb
            iChan = userData.rgbPixelChan(j);
        else
            iChan = userData.grayOverlayChan;
        end
            
        hOverlay = userData.hOverlay{userData.iOverlay}{iChan};
            
        if isempty(hOverlay) || ~all(ishandle(hOverlay))  % No overlay handles or the handles are invalid
            
            % Very very lame way to do it (but i need to visualize...)
            % Should be externalized in a class
            if isa(process,'MaskProcess')
                maskNames = process.getOutMaskFileNames(iChan);
                
                %Load the mask
                currMask = imread([ process.outFilePaths_{iChan} filesep maskNames{1}{userData.iFrame}]);
                
                %Convert the mask into a boundary
                maskBounds = bwboundaries(currMask);
                
                if isrgb
                    userData.hOverlay{userData.iOverlay}{iChan} = ...
                        cellfun(@(x)(plot(x(:,2),x(:,1),userData.colStr{j})),maskBounds);
                else
                    userData.hOverlay{userData.iOverlay}{iChan} = ...
                        cellfun(@(x)(plot(x(:,2),x(:,1),'white')), maskBounds);
                end
            elseif isa(process,'SpeckleDetectionProcess');
                cands = process.loadChannelOutput(iChan,userData.iFrame);
                validCands = vertcat(cands([cands.status]==1).Lmax);
                if ishandle(userData.hOverlay{userData.iOverlay}{iChan})
                    set(userData.hOverlay{userData.iOverlay}{iChan},...
                        'XData',validCands(:,2),'XYData',validCands(:,1));
                else
                    userData.hOverlay{userData.iOverlay}{iChan} = ...
                        plot(validCands(:,2),validCands(:,1),'or');
                end
            elseif isa(process,'FlowTrackingProcess') || isa(process,'FlowAnalysisProcess');
                flow = process.loadChannelOutput(iChan,userData.iFrame);
                userData.hOverlay{userData.iOverlay}{iChan} =...
                    quiver(flow(:, 2),flow(:, 1),...
                    flow(:, 4)-flow(:, 2), flow(:, 3)-flow(:, 1));
            end
                
        else
            if isrgb
                arrayfun( @(x)set(x, 'Visible', 'on', 'color', userData.colStr{j}), userData.hOverlay{userData.iOverlay}{iChan} )
            else
                arrayfun( @(x)set(x, 'Visible', 'on', 'color', 'r'), userData.hOverlay{userData.iOverlay}{iChan} )
            end
        end
            
    end
                
else  % Turn overlay off
        
    for j = layer
            
        if isrgb
            iChan = userData.rgbPixelChan(j);
        else
            iChan = userData.grayOverlayChan;
        end
            
        hOverlay = userData.hOverlay{userData.iOverlay}{iChan};
            
        if ~isempty(hOverlay) && all(ishandle(hOverlay))  % Overlay handles are invalid
                
        	arrayfun( @(x)set(x, 'Visible', 'off'), userData.hOverlay{userData.iOverlay}{iChan} )
        end
    end
end

set(handles.figure1, 'UserData', userData)



function submenu_overlay_Callback(hObject, eventdata, handles)
% Call back function of overlay submenu

handles = guidata(hObject);
userData = get(handles.figure1, 'UserData');


if ~userData.ini && ~isempty(userData.iOverlay)
    % Hide the RGB overlay
    drawingFigure(handles, 'overlay', 'off', 1:3)
end

userData = get(handles.figure1, 'UserData');
id = get(hObject, 'UserData');

if ~isempty(userData.iOverlay) && userData.iOverlay == id && ~userData.ini
    
    set(handles.overlayProcess(id), 'Checked', 'off')
    userData.iOverlay = [];
    userData.iOverlayChan = [];
    set(handles.text_overlay, 'String', 'None')
    set(handles.figure1, 'UserData', userData)
    
    % Set up overlay channels
    guifcn_setup_channels(handles, 'overlay')
    guifcn_enable_uipaneloverlay(handles, 'off')
    return
end

% Uncheck old overlay, check new image
if ~isempty(userData.iOverlay)
    set(handles.overlayProcess(userData.iOverlay), 'Checked', 'off')
end
set(handles.overlayProcess(id), 'Checked', 'on')

% Update user data
userData.iOverlay = id;
userData.iOverlayChan = find(userData.overlayProcess{userData.iOverlay}.checkChannelOutput);
set(handles.text_overlay, 'String', userData.overlayProcess{id}.name_)

% If no valid overlay output
if isempty(userData.iOverlayChan)
    warndlg('Warning: the current step does not have valid overlay result to display.')
    return
end

set(handles.figure1, 'UserData', userData)
guifcn_setup_channels(handles, 'overlay')
guifcn_enable_uipaneloverlay(handles, 'on')


% Assign user data: grayOverlayChan
userData.grayOverlayChan = userData.iOverlayChan(1);

% Set GUI
set(handles.popupmenu_overlay, 'Value', 1)

set(handles.figure1, 'UserData', userData)

if ~userData.ini
    % Draw new Overlay
    drawingFigure(handles, 'overlay', 'on', 1:3)
end



function submenu_image_Callback(hObject, eventdata, handles)
% Call back function of image submenu

handles = guidata(hObject);

userData = get(handles.figure1, 'UserData');
id = get(hObject, 'UserData');

if userData.iPixel == id && ~userData.ini
    return
end

if ~userData.ini
    % Hide the RGB overlay if in RGB overlay mode
    if get(handles.radiobutton_1, 'Value')
        drawingFigure(handles, 'overlay', 'off', 1:3)
    end
    userData = get(handles.figure1, 'UserData');
end

% Uncheck old image, check new image
set(handles.pixelProcess(userData.iPixel), 'Checked', 'off')
set(handles.pixelProcess(id), 'Checked', 'on')

% Update title information of GUI
userData.iPixel = id;

if id == 1
    userData.iPixelChan = 1:userData.nChan;
    set(handles.text_process, 'String', 'Raw Image')
else
    userData.iPixelChan = find(userData.pixelProcess{userData.iPixel}.checkChannelOutput);
    set(handles.text_process, 'String', userData.pixelProcess{id}.name_)
end


% If no valid output
if isempty(userData.iPixelChan)
    warndlg('Warning: the current step does not have valid result to display.')
    return
end

set(handles.figure1, 'UserData', userData)
guifcn_setup_channels(handles, 'pixel')

% Set user data, display channels for RGB and Gray
if length(userData.iPixelChan) <= 3
        
    userData.rgbPixelChan = zeros(1,3); 
    userData.rgbPixelChan(1:length(userData.iPixelChan)) = userData.iPixelChan;
else
    userData.rgbPixelChan(1:3) = userData.iPixelChan(1:3);
end

userData.grayPixelChan = userData.iPixelChan(1);

% Set GUI, display channels for RGB and Gray
for i = 1:3
    
    if userData.rgbPixelChan(i)
        % channel to display
        set(handles.rgbCheckbox(i), 'Value', 1)
        set(handles.rgbPopupmenu(i), 'Value', find( userData.iPixelChan == userData.rgbPixelChan(i)))
        
    else
        % channel not display
        set(handles.rgbCheckbox(i), 'Value', 0)
    end
    
    if get(handles.radiobutton_rgb, 'Value')
        guifcn_rgbcheckbox_color(handles.rgbCheckbox(i), handles)
    end
end
set(handles.popupmenu_gray, 'Value', 1)

set(handles.figure1, 'UserData', userData)


if ~userData.ini

    % If RGB overlay, then draw them since RGB overlay comes with the RGB image
    if get(handles.radiobutton_1, 'Value')
        drawingFigure(handles, 'overlay', 'on', 1:3)
    end
    drawingFigure(handles, 'pixel', 'on', 1:3)

end

    

function guifcn_setup_channels(handles, type)
% GUI tool function
% Reset channels in drop-down box

if nargin < 1
    error('User-defined: not enough input.')
    
elseif nargin < 2
    type = 'pixel';
end

userData = get(handles.figure1, 'UserData');

if strcmp(type, 'pixel')

    if isempty(userData.iPixelChan)
        content = {};
    else
        content = arrayfun(@(x)['Channel ' num2str(x)], userData.iPixelChan, 'UniformOutput', false);
    end

    set(handles.popupmenu_red, 'String', content, 'Value', 1)
    set(handles.popupmenu_green, 'String', content, 'Value', 1)
    set(handles.popupmenu_blue, 'String', content, 'Value', 1)
    set(handles.popupmenu_gray, 'String', content, 'Value', 1)
    
elseif strcmp(type, 'overlay')
    
    if isempty(userData.iOverlay)
        content = {''};
    else
        content = arrayfun(@(x)['Channel ' num2str(x)], userData.iOverlayChan, 'UniformOutput', false);
    end    
    
    set(handles.popupmenu_overlay, 'String', content, 'Value', 1)
end


function rgb_control_Callback(hObject, eventdata, handles)
%     userData.rgbPixelChan  
%     userData.grayPixelChan

userData = get(handles.figure1, 'UserData');

% Get RGB id
id = get(hObject, 'UserData');

if strcmp(get(hObject, 'Style'), 'checkbox')
    
    if get(hObject, 'Value')
        
        switch id
            case 1
                userData.rgbPixelChan(id) = userData.iPixelChan(get(handles.popupmenu_red, 'Value'));

            case 2
                userData.rgbPixelChan(id) = userData.iPixelChan(get(handles.popupmenu_green, 'Value'));
                
            case 3
                userData.rgbPixelChan(id) = userData.iPixelChan(get(handles.popupmenu_blue, 'Value'));
                
            otherwise 
                error('User-defined: Invalid RGB index.')
        end
        
        set(handles.figure1, 'UserData', userData);
        drawingFigure(handles, 'pixel', 'on', id)
        
        if get(handles.radiobutton_1, 'Value')
            drawingFigure(handles, 'overlay', 'on', id)
        end
        
    else
        drawingFigure(handles, 'pixel', 'off', id)
        
        % ----------- Hide Overlay --------------- 
        if get(handles.radiobutton_1, 'Value')
            sameChan = find( xor((userData.rgbPixelChan == userData.rgbPixelChan(id)),(1:3 == id)));

            drawingFigure(handles, 'overlay', 'off', id)

            if ~isempty(sameChan)
                drawingFigure(handles, 'overlay', 'on', sameChan(1))
            end
        end
        % -----------------------------------------
        
        userData = get(handles.figure1, 'UserData');
        
        userData.rgbPixelChan(id) = 0;
        set(handles.figure1, 'UserData', userData);
    end
    
    % Adjust RGB color on checkbox
    guifcn_rgbcheckbox_color(hObject, handles)
    
elseif strcmp(get(hObject, 'Style'), 'popupmenu')
    
    value = userData.rgbPixelChan(id);
    
    % Only if checkbox is checked, assign the rgb channel for display
    if value
        
         if userData.rgbPixelChan(id) == userData.iPixelChan(get(hObject, 'Value'))
            return 
         end
        
        % ----------- Hide Overlay --------------- 
        if get(handles.radiobutton_1, 'Value')
            sameChan = find( xor((userData.rgbPixelChan == userData.rgbPixelChan(id)),(1:3 == id)));
            drawingFigure(handles, 'overlay', 'off', id)
            if ~isempty(sameChan)
                drawingFigure(handles, 'overlay', 'on', sameChan(1))
            end
        end
        % -----------------------------------------
        
        userData = get(handles.figure1, 'UserData');
        
        userData.rgbPixelChan(id) = userData.iPixelChan(get(hObject, 'Value'));
        
        set(handles.figure1, 'UserData', userData);
        drawingFigure(handles, 'pixel', 'on', id)   
        if get(handles.radiobutton_1, 'Value')
            drawingFigure(handles, 'overlay', 'on', id)
        end
    end
    
else 
    error('User-defined: rgb_control_Callback function recieves an unknown uicontrol object.')
end



function [imageProcess, overlayProcess] = processParse(MD)
% This function parse all processes of movie data and sort them into two 
% catergories: image processes and overlay processes

imageProcess = {};
overlayProcess = {};

assert( isa(MD, 'MovieData'), 'User-defined: Input must be a MovieData object.')

if isempty(MD.processes_), return; end

imageProcessClasses = {'ImageProcessingProcess','SpeedMapsProcess','KineticAnalysisProcess'};
overlayProcessClasses = {'MaskProcess','SpeckleDetectionProcess',...
    'FlowTrackingProcess','FlowAnalysisProcess'};

isImageProcess  = cellfun(@(x) any(cellfun(@(y) isa(x,y),...
    imageProcessClasses)),MD.processes_);
isOverlayProcess  = cellfun(@(x) any(cellfun(@(y) isa(x,y),...
    overlayProcessClasses)),MD.processes_);
imageProcess = MD.processes_(isImageProcess);
overlayProcess = MD.processes_(isOverlayProcess);
% for i = 1:length(MD.processes_)
%     
%     % If not a valid process for display
%     if isempty(MD.processes_{i}) || ~isa(MD.processes_{i}, 'Process') || ~any( MD.processes_{i}.checkChannelOutput )
%        continue 
%     end
%     
%     % Classify the process
%     if isa(MD.processes_{i}, 'ImageProcessingProcess')
%         
%         % If pixel process
%         imageProcess = cat(2, imageProcess, {MD.processes_{i}});
%         
%     elseif isa(MD.processes_{i}, 'SegmentationProcess')
%         
%         % If overlay process
%         overlayProcess = cat(2, overlayProcess, {MD.processes_{i}});
%         
%     else
%         % warning('lccb:movieDataVisualization','User-defined: Not a supported process for display.')
%         % Not a valid process for display
%         continue;
%     end    
% 
% end
    

% --- Outputs from this function are returned to the command line.
function varargout = movieDataVisualizationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_overlay.
function popupmenu_overlay_Callback(hObject, eventdata, handles)

drawingFigure(handles, 'overlay', 'off',1)

userData = get(handles.figure1, 'UserData');
userData.grayOverlayChan = userData.iOverlayChan(get(hObject, 'Value'));
set(handles.figure1, 'UserData', userData)

drawingFigure(handles, 'overlay', 'on',1)


% --- Executes on selection change in popupmenu_gray.
function popupmenu_gray_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.grayPixelChan = userData.iPixelChan(get(hObject, 'Value'));
set(handles.figure1, 'UserData', userData)

drawingFigure(handles, 'pixel', 'on')

% --- Executes on selection change in popupmenu_colormap.
function popupmenu_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_colormap

userData = get(handles.figure1, 'UserData');

colormapStr = get(handles.popupmenu_colormap, 'String');
colormap(get(userData.hFigure, 'CurrentAxes'), colormapStr{get(handles.popupmenu_colormap, 'Value')})


% --- Executes on slider movement.
function slider_frame_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');

value = get(hObject, 'Value');

% If frame index is not an integer
if round(value) ~= value
    
    value = round(value);
    set(handles.slider_frame, 'Value', value)
end

% If same frame
if value == userData.iFrame
   return 
end

userData.iFrame = value;
set(handles.edit_frame, 'String', num2str(value))

if ~isempty(userData.hFigure) && ishandle(userData.hFigure)
   
    cla(get(userData.hFigure, 'CurrentAxes'))
    userData.hImage = [];
    userData.hOverlay = repmat({cell(1, userData.nChan)}, [1 length(userData.overlayProcess)]);
end

set(handles.figure1, 'UserData', userData)

drawingFigure(handles, 'pixel', 'on', 1:3)
drawingFigure(handles, 'overlay', 'on', 1:3)

userData = get(handles.figure1, 'UserData');
title(get(userData.hFigure, 'CurrentAxes'), [num2str(userData.iFrame) ' / ' num2str(userData.nFrames)])

function edit_frame_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
value = str2double( get(handles.edit_frame, 'String') );

if isnan(value) || value <= 0 || floor(value) ~= ceil(value)
    errordlg('Please provide a valid input for frame index.');
    set(handles.edit_frame, 'String', num2str(userData.iFrame))
    return;
    
elseif value > userData.nFrames
    errordlg(['The frame index you entered is larger than the number of frames: ' num2str(userData.nFrames) '.']);
    set(handles.edit_frame, 'String', num2str(userData.iFrame))
    return;  
end

% If same frame
if value == userData.iFrame
   return 
end

userData.iFrame = value;
set(handles.slider_frame, 'value', value)

if ~isempty(userData.hFigure) && ishandle(userData.hFigure)
   
    cla(get(userData.hFigure, 'CurrentAxes'))
    userData.hImage = [];
    userData.hOverlay = repmat({cell(1, userData.nChan)}, [1 length(userData.overlayProcess)]);
end

set(handles.figure1, 'UserData', userData)

% Draw image and overlay (if there is any)
drawingFigure(handles, 'pixel', 'on', 1:3)
% if ~isempty(userData.iOverlay)
    drawingFigure(handles, 'overlay', 'on', 1:3)
% end

userData = get(handles.figure1, 'UserData');
title(get(userData.hFigure, 'CurrentAxes'), [num2str(userData.iFrame) ' / ' num2str(userData.nFrames)])

function uipanel_display_SelectionChangeFcn(hObject, eventdata)
% Call back function of radion button group uipanel_display
handles = guidata(hObject); 
userData = get(handles.figure1, 'UserData');

switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'radiobutton_rgb'
        
        set(handles.checkbox_red, 'Enable', 'on') %, 'BackgroundColor', userData.colStr{1})
        set(handles.checkbox_green, 'Enable', 'on') %, 'BackgroundColor', userData.colStr{2})
        set(handles.checkbox_blue, 'Enable', 'on') %, 'BackgroundColor', userData.colStr{3})
        guifcn_rgbcheckbox_color(handles.checkbox_red, handles)
        guifcn_rgbcheckbox_color(handles.checkbox_green, handles)
        guifcn_rgbcheckbox_color(handles.checkbox_blue, handles)
        
        set(handles.popupmenu_red, 'Enable', 'on')
        set(handles.popupmenu_green, 'Enable', 'on')
        set(handles.popupmenu_blue, 'Enable', 'on')
        
        set(handles.popupmenu_gray, 'Enable', 'off')
        set(handles.popupmenu_colormap, 'Enable', 'off')
        set(handles.text_gray, 'Enable', 'off', 'BackgroundColor', get(handles.figure1,'color'))
        
        drawingFigure(handles, 'pixel', 'on', 1:3)
        
        
    case 'radiobutton_gray'
        
        set(handles.popupmenu_gray, 'Enable', 'on')
        set(handles.popupmenu_colormap, 'Enable', 'on')
        set(handles.text_gray, 'Enable', 'on', 'BackgroundColor', [.5 .5 .5])
        
        set(handles.checkbox_red, 'Enable', 'off', 'BackgroundColor', get(handles.figure1,'color'))
        set(handles.checkbox_green, 'Enable', 'off', 'BackgroundColor', get(handles.figure1,'color'))
        set(handles.checkbox_blue, 'Enable', 'off', 'BackgroundColor', get(handles.figure1,'color'))
        
        set(handles.popupmenu_red, 'Enable', 'off')
        set(handles.popupmenu_green, 'Enable', 'off')
        set(handles.popupmenu_blue, 'Enable', 'off')
        
        drawingFigure(handles, 'pixel', 'on')
end


function uipanel_overlay_SelectionChangeFcn(hObject, eventdata)
% Call back function of radion button group uipanel_overlay
handles = guidata(hObject); 

switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'radiobutton_1'

        set(handles.popupmenu_overlay, 'Enable', 'off')
        
        drawingFigure(handles, 'overlay', 'off', 1, 'hideGRAYoverlay')
        drawingFigure(handles, 'overlay', 'on', 1:3)
        
    case 'radiobutton_2'
      
        set(handles.popupmenu_overlay, 'Enable', 'on')
        
        drawingFigure(handles, 'overlay', 'off', 1:3, 'hideRGBoverlay')
        drawingFigure(handles, 'overlay', 'on')
end


function guifcn_rgbcheckbox_color(hObject, handles)

userData = get(handles.figure1, 'UserData');

if ~strcmp(get(hObject, 'Style'), 'checkbox')
    error('User-defined: input is not a checkbox object.') 
end

if get(hObject, 'value')
    
    set(hObject, 'ForegroundColor', 'white', 'BackgroundColor', userData.colStr{get(hObject, 'UserData')})
else
    set(hObject, 'ForegroundColor', userData.colStr{get(hObject, 'UserData')}, 'BackgroundColor', get(handles.figure1, 'color'))
end

function guifcn_enable_uipaneloverlay(handles, type)
% Enable or disable the uipanel 'Overlay'
if nargin < 2
    type = 'on';
end

if ~any( strcmp(type, {'on', 'off'}) )
    error('User-defined: Wrong input.')
end

set(handles.radiobutton_1, 'Enable', type)
set(handles.radiobutton_2, 'Enable', type)


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');

% Find all userData field ending with Fig
userDataFields=fieldnames(userData);
isFig = ~cellfun(@isempty,regexp(userDataFields,'Fig$'));
userDataFigs = userDataFields(isFig);

% Delete fields
for i=1:numel(userDataFigs)
     figHandles = userData.(userDataFigs{i});
     validFigHandles = figHandles(ishandle(figHandles)&figHandles ~= 0);
     delete(validFigHandles);
end


if isfield(userData, 'hFigure') && ~isempty(userData.hFigure) && ishandle(userData.hFigure)
   delete(userData.hFigure) 
end
