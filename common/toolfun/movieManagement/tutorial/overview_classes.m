%% MovieObject API Documentation

%% MovieData
% Initialize an empty MovieData object
MD = MovieData();

% Check class properties
disp(class(MD));

% List object superclasses
superclasses('MovieData');

% Display the object properties and methods
properties(MD);
methods(MD);

% Display MATLAB built-in help
help MovieData
help MovieData.camBitdepth_
help MovieData.load

% Display MATLAB built-in doc
doc MovieData
doc MovieData.getProcess

%%

ML = MovieList();