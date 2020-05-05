function wrapperMovieExample(movieDataOrProcess,param)
% WRAPPERMOVIEEXAMPLE Example wrapper for myFunction to be executed by
% ExampleProcess.
%
% INPUT
% movieDataOrProcess - either a MovieData (legacy)
%                      or a Process (new as of July 2016)
%
% param - (optional) A struct describing the parameters, overrides the
%                    parameters stored in the process (as of Aug 2016)
%
% OUTPUT
% none (saved to p.OutputDirectory/output.mat)
%
% See also Process.getParameters, MovieData.getOwnerAndProcess,
% Process.getOwnerAndProcess,
% isProcessOrMovieData, isProcessOrMovieList, isProcessOrMovieObject,
% NonSingularProcess

% Changes
% As of July 2016, the first argument could also be a Process. Use
% getOwnerAndProcess to simplify compatability.
%
% As of August 2016, the standard second argument should be the parameter
% structure



%% Input check
assert(isProcessOrMovieData(movieDataOrProcess), ...
    'wrappedMovieExample:IncorrectInput', ...
    'First argument should be be of class Process or MovieData');

%% Registration

% Get MovieData object and Process
% If movieDataOrProcess is a MovieData and does not contain an
% ExampleProcess, create ExampleProcess using constructor with no
% arguments.
% If movieDataOrProcess is a MovieData and does contain an ExampleProcess,
% then return the first instance of an ExampleProcess.
% If movieDataOrProcess is an ExampleProcess, then return the Process and it's
% MovieData owner.
% Otherwise throw an error.
[movieData, process] = getOwnerAndProcess(movieDataOrProcess,'ExampleProcess',true);


%% Input/output
% If parameters are explicitly given, they should be used rather than the
% one stored in ExampleProcess
if(nargin > 1)
    p = param;
else
    p = process.getParameters();
end
% The parameters in p must be a struct
assert(isstruct(p), ...
    'wrappedMovieExample:IncorrectParameters', ...
    'Parameters must be a struct');

% Output will be saved to p.OutputDirectory/output.mat
outputFile = fullfile(p.OutputDirectory, 'output.mat');
if ~isdir(p.OutputDirectory), mkdir(p.OutputDirectory), end

% logging input
nChan = numel(movieData.channels_);
inFilePaths = cell(nChan, 1);
inFilePaths{1} = movieData.channels_(1).channelPath_;
process.setInFilePaths(inFilePaths);

% logging output
nChan = numel(movieData.channels_);
outFilePaths = cell(nChan, 1);
outFilePaths{1} = outputFile;
process.setOutFilePaths(outFilePaths);


%% Algorithm

output = zeros(movieData.nFrames_, 1);
for t = 1 : movieData.nFrames_
    I = movieData.getChannel(1).loadImage(t);
    
    % Algorithm
    output(t) = myFunction(I);
        
end
save(outputFile, 'output');

end