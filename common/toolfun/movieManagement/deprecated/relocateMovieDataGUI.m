function varargout = relocateMovieDataGUI(varargin)
% RELOCATEMOVIEDATAGUI M-file for relocateMovieDataGUI.fig
%      RELOCATEMOVIEDATAGUI, by itself, creates a new RELOCATEMOVIEDATAGUI or raises the existing
%      singleton*.
%
%      H = RELOCATEMOVIEDATAGUI returns the handle to a new RELOCATEMOVIEDATAGUI or the handle to
%      the existing singleton*.
%
%      RELOCATEMOVIEDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RELOCATEMOVIEDATAGUI.M with the given input arguments.
%
%      RELOCATEMOVIEDATAGUI('Property','Value',...) creates a new RELOCATEMOVIEDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before relocateMovieDataGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to relocateMovieDataGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help relocateMovieDataGUI

% Last Modified by GUIDE v2.5 12-Aug-2010 23:16:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @relocateMovieDataGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @relocateMovieDataGUI_OutputFcn, ...
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


% --- Executes just before relocateMovieDataGUI is made visible.
function relocateMovieDataGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% 
% relocateMovieDataGUI(ML, index, 'mainFig', handles.figure1)
% 
% User Data:
% 
% userData.MD - the array of new movie data 
% userData.ML - the movie list
% 
% userData.mainFig - handle of movie selector GUI
% userData.handles_main - 'handles' of movie selector GUI
%
% userData.newFig - handle of movieDataGUI
% 
% userData.userDir - default open directory
% 

[copyright] = getLCCBCopyright(handles);
set(handles.text_copyright, 'String', copyright)

userData = get(handles.figure1, 'UserData');
% Choose default command line output for relocateMovieDataGUI
handles.output = hObject;

userData.MD = [ ];

if nargin>3
    assert( isa(varargin{1}, 'MovieList'), 'User-defined: The firest input of relocateMovieDataGUI should be a MovieList object')
    userData.ML = varargin{1};
    l = length(userData.ML.movieDataFile_);
    
    if any(arrayfun(@(x)(x > l), varargin{2}, 'UniformOutput', true))
        error('User-defined: input index should be smaller than the length of movie data.')
    end
    
    t = find(strcmp(varargin, 'mainFig'));
    assert( ~isempty(t), 'User-defined: Need to pass the handle of main figure as input.')
    userData.mainFig = varargin{t+1};
    userData.handles_main = guidata(userData.mainFig);
    
    userData_main = get(userData.mainFig, 'UserData');
    userData.userDir = userData_main.userDir;
    
    % GUI set-up
    set(handles.listbox_unfound, 'string', userData.ML.movieDataFile_(varargin{2}), ...
        'UserData',  varargin{2})
    
else
    error('User-defined: Not enough input arguments.')
end


set(handles.figure1,'UserData',userData)
guidata(hObject, handles);

% UIWAIT makes relocateMovieDataGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = relocateMovieDataGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1)

% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
userData_main = get(userData.handles_main.figure1, 'UserData');

contentlist1 = get(handles.listbox_unfound, 'String');
contentlist2 = get(handles.listbox_new, 'String');

% If nothing is in the new movie list
if isempty(contentlist2)
    
    user_response = questdlg('There is no new movie data path. Are you sure not to relocate any movie and close the window?', 'Relocate Movie Data', 'Yes','No','No');
    switch lower(user_response)
        case 'yes'
            delete(handles.figure1)
            return
        case 'no'
            return
    end
end

userData_list1 = get(handles.listbox_unfound, 'UserData');
userData_list2 = get(handles.listbox_new, 'UserData');

assert(length(userData.MD) == length(contentlist2), 'User-defined: GUI error, the length of movie data is inconsistant with the length of movie data path in new list box.')

% Assign new movie data path
userData.ML.editMovieDataFile(userData_list2, contentlist2)
userData.ML.save;

% Ask if user want to keep or remove un-relocated movie data
if ~isempty(contentlist1)
    filemsg = '';
    for i = 1: length(userData_list1)
        filemsg = cat(2, filemsg, sprintf('\n%s', contentlist1{i}));
    end
    msg = sprintf('The following movie data have not been relocated:\n%s\n\nDo you want to remove the above movies in movielist %s?', filemsg, userData.ML.movieListFileName_);
    user_response = questdlg(msg, 'Remove Movie Data', 'Keep Movie(s)', 'Remove Movie(s)', 'Keep Movie(s)');
    
    if strcmpi(user_response, 'remove movie(s)')
        
        userData.ML.removeMovieDataFile(userData_list1)
        userData.ML.save;
        
    end
    
end

if get(handles.checkbox_load, 'Value')

% userData.MD, contentlist2  - duplicate movie in movie list box
contentlist_movie = get(userData.handles_main.listbox_movie, 'String');

temp = cellfun(@(x)any(strcmp(x, contentlist_movie)), contentlist2);

if any(temp)
    
    filemsg = '';
    for i = find(temp)
        filemsg = cat(2, filemsg, sprintf('\n%s', contentlist2{i}));
    end
    msg = sprintf('The following movie data already exist in movie list box:\n%s', filemsg);
    warndlg(msg, 'Warning')
end

% Add Movie data to movie selector
contentlist_movie = cat(1, contentlist_movie, contentlist2(~temp));
userData_main.MD = cat(2, userData_main.MD, userData.MD(~temp) );

set(userData.handles_main.listbox_movie, 'String', contentlist_movie)
set(userData.handles_main.figure1, 'UserData', userData_main)

end

delete(handles.figure1)

% --- Executes on selection change in listbox_unfound.
function listbox_unfound_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_unfound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_unfound contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_unfound


% --- Executes during object creation, after setting all properties.
function listbox_unfound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_unfound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_relocate.
function pushbutton_relocate_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'userdata');

contentlist1 = get(handles.listbox_unfound, 'String');
contentlist2 = get(handles.listbox_new, 'String');

if isempty(contentlist1)
    return
end

userData_list1 = get(handles.listbox_unfound, 'UserData');
userData_list2 = get(handles.listbox_new, 'UserData');

id = get(handles.listbox_unfound, 'value');

[filename, pathname] = uigetfile('*.mat','Select Movie Data MAT file', userData.userDir);
if ~any([filename pathname])
    return;
else
    userData.userDir = pathname;
end

% Make sure no duplicate movie data in the list
if any( strcmp([filename pathname], userData.ML.movieDataFile_) )
    msg = sprintf('Movie data:\n\n%s\n\n is already in the movie list %s. Please select another movie data', [filename pathname], userData.ML.movieListFileName_);
    warndlg(msg, 'Relocate Movie Data', 'modal')
    return
end

% Open and validate the MAT file
try
   pre = whos('-file', [pathname filename]); 
catch ME
    errordlg(ME.message, 'Fail to open the selected MAT file.', 'modal')
    return
end

structM = pre( logical(strcmp({pre(:).class},'MovieData')) );

switch length(structM)
    case 1
        load([pathname filename],'-mat',structM.name);
        eval(['MD =' structM.name ';']);  
        
    case 0
        errordlg('No movie data is found in the selected MAT file.',...
            'MAT File Error','modal')
        return
        
    otherwise
        errordlg('The selected MAT file contains more than one movie data.',...
                'MAT File Error','modal');
        return        
end

% Validate the movie data
try
    MD.sanityCheck(pathname, filename)
    
catch ME
    if isfield(userData, 'newFig') && ishandle(userData.newFig)
        delete(userData.newFig)
    end

    userData.newFig = movieDataGUI(MD);
    msg = sprintf('Movie Data: %s\n\nError: %s\n\nMovie data is not successfully loaded. Please refer to movie detail, adjust your data and try again.', [pathname filename], ME.message);
    errordlg(msg, 'Movie Data Error','modal'); 
    return
end

userData.MD = cat(2, userData.MD, MD);

contentlist2{end+1} = [pathname filename];
userData_list2(end +1) = userData_list1(id);

contentlist1(id) = [];
userData_list1(id) = [];

if (id > length(contentlist1) && id > 1)
    set(handles.listbox_unfound, 'Value', length(contentlist1));
end

set(handles.listbox_unfound, 'String', contentlist1, 'UserData', userData_list1)
set(handles.listbox_new, 'String', contentlist2, 'UserData', userData_list2)

set(handles.figure1, 'UserData', userData);


% --- Executes on selection change in listbox_new.
function listbox_new_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_new contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_new


% --- Executes during object creation, after setting all properties.
function listbox_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_remove.
function pushbutton_remove_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');

contentlist1 = get(handles.listbox_unfound, 'String');
contentlist2 = get(handles.listbox_new, 'String');

if isempty(contentlist2)
    return
end

userData_list1 = get(handles.listbox_unfound, 'UserData');
userData_list2 = get(handles.listbox_new, 'UserData');

id = get(handles.listbox_new, 'value');

userData.MD(id) = [];

contentlist1{end + 1} = userData.ML.movieDataFile_{userData_list2(id)};
userData_list1(end+1) = userData_list2(id);

contentlist2(id) = [];
userData_list2(id) = [];

if (id > length(contentlist2) && id > 1)
    set(handles.listbox_new, 'Value', length(contentlist2));
end

set(handles.listbox_unfound, 'String', contentlist1, 'UserData', userData_list1)
set(handles.listbox_new, 'String', contentlist2, 'UserData', userData_list2)

set(handles.figure1, 'UserData', userData);



% --- Executes on button press in checkbox_load.
function checkbox_load_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_load
if get(hObject, 'Value')
    set(handles.pushbutton_done, 'string', 'Save and Load Movie')
else
    set(handles.pushbutton_done, 'string', 'Save Movie')
end
