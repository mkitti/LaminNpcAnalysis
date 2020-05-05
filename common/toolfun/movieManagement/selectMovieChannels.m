function iChannels = selectMovieChannels(movieData,multiple,promptString)

%
% iChannels = selectMovieChannels(movieData,multiple,promptString)
%
% Allows the user to select channel(s) from those available in the input
% movie and returns their index.
%
% Input:
%
%   movieData - Object describing movie. An object of the 'MovieData'
%   class.
%
%   multiple  - If true, multiple channels can be selected, if false, only
%   one can be selected.
%
%   promptString - Character string with the prompt to display above the
%   selection dialogue box.
%
%
% Output:
%
%   iChannels - The integer index of the channels selected.
%
% Hunter Elliott, 10/2009
% Revamped 5/2010
%

if ~isa(movieData,'MovieData')    
    error('First input must be a valid MovieData object!')                
end

if nargin < 2 || isempty(multiple)
    multiple = true;
end

if nargin < 3 || isempty(promptString)
    if multiple
        promptString = 'Please select the channel(s):';        
    else
        promptString = 'Please select a channel:';        
    end    
end

if multiple
    sMode = 'multiple';
else
    sMode = 'single';
end

chanList = movieData.getChannelPaths;

if length(chanList) == 1
    iChannels = 1;
    
elseif length(chanList) > 1

    [iChannels,OK] = listdlg('PromptString',promptString,...
                    'SelectionMode',sMode,...
                    'ListString',chanList,...
                    'ListSize',[600 600]);

    if isempty(iChannels) || ~OK
        error('Must select at least one channel to continue!')
    end
else
   error('The input movieData does not contain any channels! Check moviedData!') 
end
        