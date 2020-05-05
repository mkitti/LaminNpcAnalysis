function s = loadLCCBIcons(s)
% Load set of common icons for graphical interfaces
% 
% Synopsis: icons = loadLCCBIcons(s)
% 
% Input:
%         s - an existing structure to which fields corresponding to each
%         icon will be appending. A new structure will be created if empty.
%
% Output:
%         s - a structure with a series of fields named xxxIconData which
%         value corresponds to the TrueColor icon data
%
% Sebastien Besson, June 2012

% Get the main path to the icons folder
iconsPath = fullfile(fileparts(which('packageGUI.m')),'icons');

% Create 
iconsNames ={'pass','accepted 48 32x32.png';'error','cancel 48 32x32.png';...
    'warn','warning 48 32x32.png';'quest','dialog-question-48x48.png';...
    'smallquest','dialog-question-22x22.png';'open','document-open-8.png'};

% Create options to set the background
bgOptions = {'BackgroundColor',get(0,'DefaultUiControlBackgroundColor')};

for i=1:size(iconsNames,1)
    s.([iconsNames{i,1} 'IconData']) = ...
        imread(fullfile(iconsPath,iconsNames{i,2}),bgOptions{:});
end

end