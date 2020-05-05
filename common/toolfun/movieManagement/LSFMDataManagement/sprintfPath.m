function path=sprintfPath(XYProjTemplate,varargin)
% making sprintf windows-path-proof
% sprintf applied on the filename only
[folder,file,ext]=fileparts(XYProjTemplate);
filename=sprintf(file,varargin{:});
path=fullfile(folder,[filename ext]);
