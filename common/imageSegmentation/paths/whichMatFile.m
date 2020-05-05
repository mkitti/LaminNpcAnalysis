function [ fullFileName ] = whichMatFile( filename )
%whichMatFile Finds the location of the filename on the path
%
% The function first searches in the current working directory (quick). If
% this fails, then it uses matfile to locate the file.
% 
% INPUT
% filename is an absolute or relative path for matfile
%
% OUTPUT
% fullFileName is the full file name of the file that would be loaded by
% the builtin load function
%
% See also matfile
%
% Mark Kittisopikul
% December 2014

% check if file exists in pwd or is absolute 
[s,attrib] = fileattrib(filename);
if(s)
    fullFileName = attrib.Name;
else
    % this is a potentially expensive operation
    matObj = matfile(filename);
    fullFileName = [];
    if(exist(matObj.Properties.Source,'file'))
        fullFileName = matObj.Properties.Source;
    end
    % free memory
    delete(matObj);
end

end

