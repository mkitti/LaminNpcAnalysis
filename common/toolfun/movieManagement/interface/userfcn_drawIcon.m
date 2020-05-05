function userfcn_drawIcon(handles, type, ID, msg, savetogui)
% This function draw or clears process status icons on package GUI
% The tag of checkboxes of processes are defined as the following format:
% 
% axes_icon_1, axes_icon_2, ..., axes_icon_n
%
% Input:
%   handles - structure handles of package GUI
%   type - the type of icons, if type = 'clear', then clears the icons of
%          processes specified by 'ID'
%   ID - array of the id of processes to draw icons specified by type and
%        msg
%   msg (optional) - icon message
%   savetogui (optional) - true or false, if save icon and message to user data,
%                          default is true
%   userData (optional) - if savetogui = true, userData is passed by main function
%
%
% Chuangang Ren
% 08/2010

userData = get(handles.figure1, 'UserData');

if nargin < 4
    msg = '';
    savetogui = false;
    
elseif nargin < 5
    savetogui = false;

end

switch type
    case 'pass'
        iconData = userData.passIconData;
        
    case 'error'
        iconData = userData.errorIconData;
        
    case 'warn'
        iconData = userData.warnIconData;
        
    case 'clear'
        for i = ID
            cla(handles.(['axes_icon_' ,num2str(i)]));
            if savetogui
               % Save icon and message to user data
               userData.statusM(userData.id).IconType{i} = [];
               userData.statusM(userData.id).Msg{i} = [];
               set(handles.figure1, 'UserData', userData)                
            end
        end
        return
        
    otherwise
        error('User-defined: function input ''type'' is incorrect');
        
end

for i = ID
    
    axes(handles.(['axes_icon_',num2str(i)]));
    Img = image(iconData);
    set(gca, 'Tag', ['axes_icon_' num2str(i)], 'XLim',get(Img,'XData'),'YLim',get(Img,'YData'), 'visible','off','YDir','reverse' )
    set(Img,'ButtonDownFcn',@icon_ButtonDownFcn)
    set(Img,'UserData',msg)
    
    if savetogui
        % Save icon and message to user data
        userData.statusM(userData.id).IconType{i} = type;
        userData.statusM(userData.id).Msg{i} = msg;
        set(handles.figure1, 'UserData', userData)    
    end

end
