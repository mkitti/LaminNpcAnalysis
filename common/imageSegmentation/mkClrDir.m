function mkClrDir(dirPath,verbose)
%MKCLRDIR makes sure that the specified directory exists AND is empty 
% 
% This is just a little function for creating / settin up output
% directories. It checks if a directory exists and if not, makes it. If the
% directories does exist and contains files, these are deleted.
% 
% Input:
% 
%   dirPath - the path to the directory to make/clear.
% 
% Hunter Elliott
% 6/2010

if nargin < 1 || isempty(dirPath)
    error('You must specify the directory to set up!')
end
if nargin < 2
    verbose=true;
end

if ~exist(dirPath,'dir')
    try
        mkdir(dirPath)
    catch
        try
            system(['mkdir -p "' dirPath '"']);
        catch
            [upperPath,curFolderName] = fileparts(dirPath);
            cd(upperPath)
            system(['mkdir -p "' curFolderName '"']);
        end
    end
else
    %Check for files in the directory
    inDir = dir([dirPath filesep '*']);
    if ~isempty(inDir)
        %Remove the . and .. from dir (on linux)
        inDir = inDir(arrayfun(@(x)(~strcmp('.',x.name) ...
            && ~strcmp('..',x.name)),inDir));
        for i = 1:numel(inDir)
            if inDir(i).isdir
                rmdir([dirPath filesep inDir(i).name],'s');
            else
                delete([dirPath filesep inDir(i).name]);
            end
        end
    end
    if(verbose)
        display(['The folder ' dirPath ' already existed. Cleaning the folder ...'])
    end
end