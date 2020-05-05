
function checked = userfcn_saveCheckbox(handles)
% GUI tool function - return the check/uncheck status of checkbox of 
% processes in package control panel 
%
% Input:
%
%   handles - the "handles" of package control panel movie 
%   
% Output:
%
%   checked - array of check/unchecked status  1 - checked, 0 - unchecked
%
%
% Chuangang Ren
% 08/2010

userData = get(handles.figure1, 'UserData');
l = 1:size(userData.dependM, 1);

checked = arrayfun( @(x) get(handles.(['checkbox_' num2str(x)]), 'Value'), l, 'UniformOutput', true);
