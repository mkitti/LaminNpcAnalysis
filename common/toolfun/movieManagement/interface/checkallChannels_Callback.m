function checkallChannels_Callback(hObject, eventdata, handles)

% Retrieve available channels properties
availableProps = get(handles.listbox_availableChannels, {'String','UserData'});
if isempty(availableProps{1}), return; end

% Update selected channels
if get(hObject,'Value')
    set(handles.listbox_selectedChannels, 'String', availableProps{1},...
        'UserData',availableProps{2});
else
    set(handles.listbox_selectedChannels, 'String', {}, 'UserData',[], 'Value',1);
end