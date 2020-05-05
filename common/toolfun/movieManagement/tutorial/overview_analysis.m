%% Load a rich MovieData object
% Load the MAT file
% savedMoviePath = '~/Desktop/SoftwareDay-Data/QFSM/cont1/movieData.mat';
% MD = MovieData.load(savedMoviePath);

% initialization movie data
init_moviedata();

%% 

MD.addProcess(ExampleProcess(MD));
MD.addPackage(ExamplePackage(MD));
% may need to add a process

%% Analysis

disp('Analysis');
fprintf(1, 'Analysis saved under: %s\n', MD.outputDirectory_);

% List the processes
fprintf(1, 'Number of analysis processes: %g\n', numel(MD.processes_));
for i = 1 : numel(MD.processes_)
    fprintf(1, '   Process %g: %s\n', i, MD.getProcess(i).getName());
end

% List the packages
fprintf(1, 'Number of analysis packages: %g\n', numel(MD.packages_));
for i = 1 : numel(MD.packages_)
    fprintf(1, '   Package %g: %s\n', i, MD.getPackage(i).getName());
end

%% Process

% Retrieve second analysis process of the processes list
process = MD.getProcess(1);
fprintf(1, 'Process %g: %s\n', 1, process.getName());

% Retrieve analysis parameters
params = MD.getProcess(1).funParams_;
disp('Parameters');
disp('  Process parameters:');
disp(params);
disp('  Default parameters:');
disp(MD.getProcess(1).getDefaultParams(MD));

% Retrieve analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Retrieve analysis time metrics
disp('Time');
fprintf(1,'  Last run started at: %s\n', datestr(process.startTime_));
fprintf(1,'  Last run ended at: %s\n', datestr(process.finishTime_));
fprintf(1,'  Last run lasted: %s\n', process.getProcessingTime().str);

% Read process output
disp('Output');
fprintf(1, '  Output saved under: %s\n', process.outFilePaths_{1});
% Load mask output
mask = process.loadChannelOutput(1, 1);
figure; imshow(mask, []);

% Overlay default output visualization (line)
figure;
MD.getChannel(1).draw(1);
process.draw(1, 1);

%% Package

% Retrieve first analysis package
package = MD.getPackage(1);
fprintf(1, 'Package %g: %s\n', 1, package.getName());

% Retrieve list of processes
classNames = package.getProcessClassNames();
for i = 1:numel(classNames)
    fprintf(1, '  Process %i: %s\n', i, classNames{i});
end

% Read process output
disp('Output');
fprintf(1, '  Output saved under: %s\n', package.outputDirectory_);

% Retrieve first process of second package
process = MD.getPackage(1).getProcess(1);

% Launch the movie viewer
movieViewer(MD);