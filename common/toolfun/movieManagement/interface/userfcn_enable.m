function userfcn_enable (index, onoff, handles, check)
% GUI tool function: this function is used to change the 'visible' property 
% of uicontrols on control panel. The name of the uicontrols are pre-defined
% in the following way: 
%       checkbox: 
%               checkbox_1  checkbox_2 ...
%
% Input: 
%       index - vector of check box index
%       onoff - enable or disable, 'on' or 'off'
%       handles - handles of control panel
%       check - (Optional) true or false. It provides a option to select/unselect 
%       the checkboxs that have been enabled/disabled.
% 
% Chuangang Ren
% 08/2010

if nargin < 4
    check = false;
end

for i = index(:)'
    set(handles.(['checkbox_',num2str(i)]),'Enable',onoff);
    set(handles.(['pushbutton_set_',num2str(i)]),'Enable',onoff);                                    
end

if check
    switch onoff
        case 'on'
            value=1;
        case 'off'
            value=0;
    end
    for i = 1: length(index)
        set(handles.(['checkbox_',num2str(index(i))]),'Value',value);
    end

end