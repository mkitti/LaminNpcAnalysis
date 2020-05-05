%% Analysis set-up via Command line


%% Initialization

% dvPath = '~/Desktop/2014Mar26/Actin-TM2.ome.tif';
% MD = MovieData(dvPath);
% fprintf(1, 'Object saved under: %s\n', MD.getFullPath());
% fprintf(1, 'Output directory for analysis: %s\n', MD.outputDirectory_);

% use default MD initialization
init_moviedata;

% currently fails with error:
%   Error using thresholdMovie (line 220)
%   Could not automatically select a threshold in frame 18! Try specifying a threshold level, or
%   enabling the MaxJump option!
% 

%% Reset

% Reset analysis
MD.reset();

%% Creation and status

% Set-up process via command line interace
process = ThresholdProcess(MD);
MD.addProcess(process);
processIndex = process.getIndex();
parameters = process.getParameters();

fprintf(1, 'Process %g: %s\n', processIndex, process.getName());

% Retrieve analysis parameters
disp('Parameters');
disp(parameters);
disp('  Default parameters:');
disp(MD.getProcess(processIndex).getDefaultParams(MD));

% Initial analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end


%% Run

% Run the first process
process.run();

% Post-run status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Run the first process
fprintf(1,'Output');
processedChannels = find(process.checkChannelOutput());
fprintf(1,'  Channel with a valid output:%g', processedChannels);

%% Parameters modification

% Retrieve parameters and modify them
parameters = process.getParameters();
fprintf(1, 'Gaussian filter standard-deviation: %g\n',...
    parameters.GaussFilterSigma);
parameters.GaussFilterSigma = 1 - parameters.GaussFilterSigma;
disp('Setting new parameters');
process.setParameters(parameters);
fprintf(1, 'Gaussian filter standard-deviation: %g\n',...
    process.getParameters().GaussFilterSigma);

% Post parameters modification analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Second run of the process
process.run();

% Post-run analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

%% Process chaining

% Set-up second process via command line interace
process2 = MaskRefinementProcess(MD);
MD.addProcess(process2);
processIndex2 = process2.getIndex();
parameters = process2.getParameters();

fprintf(1, 'Process %g: %s\n', processIndex2, process2.getName());

% Initial analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process2.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process2.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process2.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Run second process
process2.run();

% Input/output
disp('Input');
fprintf(1, '  Channel %g: %s\n', 1, process2.inFilePaths_{1});
fprintf(1, '  Channel %g: %s\n', 2, process2.inFilePaths_{2});

disp('Output');
fprintf(1, '  Channel %g: %s\n', 1, process2.outFilePaths_{1});
fprintf(1, '  Channel %g: %s\n', 2, process2.outFilePaths_{2});


%%

