function varargout = viewMaskRefinementProcessGUI(varargin)
% VIEWMASKREFINEMENTPROCESSGUI M-file for viewMaskRefinementProcessGUI.fig
%      VIEWMASKREFINEMENTPROCESSGUI, by itself, creates a new VIEWMASKREFINEMENTPROCESSGUI or raises the existing
%      singleton*.
%
%      H = VIEWMASKREFINEMENTPROCESSGUI returns the handle to a new VIEWMASKREFINEMENTPROCESSGUI or the handle to
%      the existing singleton*.
%
%      VIEWMASKREFINEMENTPROCESSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWMASKREFINEMENTPROCESSGUI.M with the given input arguments.
%
%      VIEWMASKREFINEMENTPROCESSGUI('Property','Value',...) creates a new VIEWMASKREFINEMENTPROCESSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewMaskRefinementProcessGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewMaskRefinementProcessGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewMaskRefinementProcessGUI

% Last Modified by GUIDE v2.5 24-Sep-2010 13:40:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewMaskRefinementProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @viewMaskRefinementProcessGUI_OutputFcn, ...
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


% --- Executes just before viewMaskRefinementProcessGUI is made visible.
function viewMaskRefinementProcessGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Available tools 
% hfig = viewThresholdProcessGUI(process, 'mainFig',handles.figure1);
%
% UserData data:
%       userData.mainFig - handle of main figure
%       userData.crtProc - handle of current process
%       userData.MD - the Movie Data where crtProc belongs to
%
%       userData.questIconData - help icon image information
%       userData.colormap - color map information
%

userData = get(handles.figure1, 'UserData');
% Choose default command line output for viewThresholdProcessGUI
handles.output = hObject;

% Get main figure handle and process id
t = find(strcmp(varargin,'mainFig'));
userData.mainFig = varargin{t+1};

if ~isa(varargin{1}, 'MaskRefinementProcess');
    error('User-defined: input must be a MaskRefinement Process.')
end
userData.crtProc = varargin{1};
userData.MD = userData.crtProc.owner_;



% ---------------------- Channel Setup -------------------------

funParams = userData.crtProc.funParams_;

% Set up available input channels
set(handles.listbox_1, 'String', {userData.MD.channels_.channelPath_},...
        'Userdata', 1: length(userData.MD.channels_));
    
set(handles.listbox_2, 'String', ...
        {userData.MD.channels_(funParams.ChannelIndex).channelPath_}, ...
        'Userdata',funParams.ChannelIndex);
    

% ---------------------- Parameter Setup -----------------------

if funParams.MaskCleanUp
    if ~funParams.FillHoles
        set(handles.checkbox_fillholes, 'Value', 0)
    end
    set(handles.edit_1, 'String',num2str(funParams.MinimumSize))
    set(handles.edit_2, 'String',num2str(funParams.ClosureRadius))
    set(handles.edit_3, 'String',num2str(funParams.ObjectNumber))
else
    set(handles.checkbox_cleanup, 'Value', 0)
    set(handles.checkbox_fillholes, 'Value', 0, 'Enable','off')
    set(handles.text_para1, 'Enable', 'off');
    set(handles.text_para2, 'Enable', 'off');
    set(handles.text_para3, 'Enable', 'off');
    set(handles.edit_1, 'Enable', 'off');
    set(handles.edit_2, 'Enable', 'off');
    set(handles.edit_3, 'Enable', 'off');
end

if funParams.EdgeRefinement
    set(handles.checkbox_edge, 'Value', 1)
    set(handles.text_para4, 'Enable', 'on');
    set(handles.text_para5, 'Enable', 'on');
    set(handles.text_para6, 'Enable', 'on');
    set(handles.edit_4, 'Enable', 'on', 'String',num2str(funParams.MaxEdgeAdjust));
    set(handles.edit_5, 'Enable', 'on', 'String',num2str(funParams.MaxEdgeGap));
    set(handles.edit_6, 'Enable', 'on', 'String',num2str(funParams.PreEdgeGrow));    
    
end
    

% ----------------------Set up help icon------------------------

% Load icon images from dialogicons.mat
load lccbGuiIcons.mat

% Save Icon data to GUI data
userData.passIconData = passIconData;
userData.errorIconData = errorIconData;
userData.warnIconData = warnIconData;
userData.questIconData = questIconData;

% Set figure colormap
supermap(1,:) = get(hObject,'color');
set(hObject,'colormap',supermap);

userData.colormap = supermap;

% Set up help icon
set(hObject,'colormap',userData.colormap);
% Set up package help. Package icon is tagged as '0'
axes(handles.axes_help);
Img = image(userData.questIconData); 
set(gca, 'XLim',get(Img,'XData'),'YLim',get(Img,'YData'),...
    'visible','off','YDir','reverse');
set(Img,'ButtonDownFcn',@icon_ButtonDownFcn);
set(Img, 'UserData',  struct('class',class(userData.crtProc)))

% ----------------------------------------------------------------

% Update user data and GUI data
set(hObject, 'UserData', userData);

uicontrol(handles.pushbutton_done);
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = viewMaskRefinementProcessGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% Call back function of 'Apply' button

delete(handles.figure1)

% --- Executes on selection change in listbox_1.
function listbox_1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_1


% --- Executes during object creation, after setting all properties.
function listbox_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_all.
function checkbox_all_Callback(hObject, eventdata, handles)




% --- Executes on button press in pushbutton_select.
function pushbutton_select_Callback(hObject, eventdata, handles)




% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)


% --- Executes on selection change in listbox_2.
function listbox_2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_2


% --- Executes during object creation, after setting all properties.
function listbox_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_cleanup.
function checkbox_cleanup_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_auto



function edit_1_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes during object creation, after setting all properties.
function edit_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_2_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes during object creation, after setting all properties.
function edit_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_3_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes during object creation, after setting all properties.
function edit_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_fillholes.
function checkbox_fillholes_Callback(hObject, eventdata, handles)



% --- Executes on button press in checkbox_edge.
function checkbox_edge_Callback(hObject, eventdata, handles)


function edit_4_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes during object creation, after setting all properties.
function edit_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_5_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes during object creation, after setting all properties.
function edit_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_6_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes during object creation, after setting all properties.
function edit_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
userData = get(handles.figure1, 'UserData');

if isfield(userData, 'helpFig') && ishandle(userData.helpFig)
   delete(userData.helpFig) 
end

set(handles.figure1, 'UserData', userData);
guidata(hObject,handles);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end


% --- Executes on key press with focus on pushbutton_done and none of its controls.
function pushbutton_done_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end


% --- Executes on button press in checkbox_applytoall.
function checkbox_applytoall_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_applytoall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_applytoall
