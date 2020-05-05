%% Initialization/constructor
% Define original paths

% Create individual movies
MDs(3, 1) = MovieData();
for i = 1 : numel(MDs)
    MDs(i) = init_moviedata();
end

% Create movie list
% Create temporary directory
java_tmpdir = char(java.lang.System.getProperty('java.io.tmpdir'));
% Split UUID into two lines since MATLAB complains:
% 'Static method or constructor invocations cannot be indexed.'
uuid = java.util.UUID.randomUUID();
uuid = char(uuid.toString());
tmpdir = fullfile(java_tmpdir, uuid);
mkdir(tmpdir);

ML = MovieList(MDs, tmpdir);

%% Manipulation via CLI

% Set path properties
ML.setPath(tmpdir);
ML.setFilename('movieList.mat');

% Save list
ML.save();
fprintf(1, 'Movie list saved under: %s\n', ML.getFullPath());

%% Movie access
% Retrieve individual movies
disp('Movies')
for i = 1 : numel(ML.getMovies())
    fprintf(1, '  Movie %g: %s\n', i, ML.getMovie(i).getFullPath());
end

%
disp('Output')
fprintf(1, '  Analysis saved under: %s\n', ML.outputDirectory_);

%% Graphical interface

% Launch viewing interface
movieViewer(ML);