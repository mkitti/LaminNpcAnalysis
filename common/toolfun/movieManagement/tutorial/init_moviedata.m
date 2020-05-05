function MD = init_moviedata(varargin)
%% TutorialCreate a MovieData object

ip = inputParser();
ip.addOptional('filePath', '', @ischar);
ip.parse(varargin{:});

%% Data setup
% Provide your own filePath if you would like.
% Otherwise, we will create fake sample data
if isempty(ip.Results.filePath)
    
    % Creating a fake file in a temporary directory for testing purposes
    
    % Create temporary directory
    java_tmpdir = char(java.lang.System.getProperty('java.io.tmpdir'));
    % Split UUID into two lines since MATLAB complains:
    % 'Static method or constructor invocations cannot be indexed.'
    uuid = java.util.UUID.randomUUID();
    uuid = char(uuid.toString());
    tmpdir = fullfile(java_tmpdir, uuid);
    mkdir(tmpdir);
    
    % Create .fake file readable by Bio-Formats
    filePath = fullfile(tmpdir, 'test&sizeC=3&sizeZ=4&sizeT=10.fake');
    fid = fopen(filePath, 'w+');
    fclose(fid);
    
end

%% MovieData initialization

% You can also provide your own MovieData object called MD
if ~exist('MD','var') || nargout > 0
    % Using this constructor, filePath refers the full path to any file
    % readable by Bio-Formats.
    %
    % For example:
    %
    %     filePath = '/home/user/Desktop/2014Mar20/110609_RhoWT_glycofect_001.dv';
    %
    % See http://www.openmicroscopy.org/site/support/bio-formats5/supported-formats.html
    MD = MovieData(filePath);
    fprintf(1, 'filePath: %s\n',filePath);
end
fprintf(1, 'Object saved under: %s\n', MD.getFullPath());
fprintf(1, 'Output directory for analysis: %s\n', MD.outputDirectory_);