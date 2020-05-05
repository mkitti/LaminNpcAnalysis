%% Analysis set-up via Command line


%% Initialization

% Create temporary directory
java_tmpdir = char(java.lang.System.getProperty('java.io.tmpdir'));
% Split UUID into two lines since MATLAB complains:
% 'Static method or constructor invocations cannot be indexed.'
uuid = java.util.UUID.randomUUID();
uuid = char(uuid.toString());
tmpdir = fullfile(java_tmpdir, uuid);
mkdir(tmpdir);


% Download test data for u-track
url =  'http://downloads.openmicroscopy.org/images/u-track/integrins.zip';
zipPath = fullfile(tmpdir, 'integrins.zip');
urlwrite(url, zipPath);

% Unzip test imagesa
unzip(zipPath, tmpdir);

% Initialize MovieData from high SNR example
omeTiffPath = fullfile(tmpdir, 'case1_higherSNR.ome.tiff');
MD = MovieData(omeTiffPath);

%%

% Reset analysis
MD.reset();

% Set-up analysis infrastructure via command line interace
MD.addPackage(UTrackPackage(MD));
MD.getPackage(1).createDefaultProcess(1);
process = MD.getPackage(1).getProcess(1);

% Initial analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Run the first process
MD.getPackage(1).getProcess(1).run();

% Post-run status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Parameters modification
funParams = MD.getPackage(1).getProcess(1).funParams_;
funParams.lastImageNum = 5;
disp('Setting new parameters');
MD.getPackage(1).getProcess(1).setPara(funParams);

% Post parameters modification analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Second run of the first process
MD.getPackage(1).getProcess(1).run();

% Post parameters modification analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

%% Setup another process
% Setup the second process
if isempty(MD.getPackage(1).processes_{2});
    MD.getPackage(1).createDefaultProcess(2);
end
process = MD.getPackage(1).getProcess(2);

% Run the tracking process
MD.getPackage(1).getProcess(2).run();

% Post parameters modification analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end

% Parameters modification
funParams = MD.getPackage(1).getProcess(1).funParams_;
funParams.lastImageNum = 10;
disp('Setting new parameters');
MD.getPackage(1).getProcess(1).setPara(funParams);

% Post parameters modification analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');

% Run the detection & tracking process
MD.getPackage(1).getProcess(1).run();
MD.getPackage(1).getProcess(2).run();

% Post parameters modification analysis status
disp('Status');
fprintf(1,'  Process has been run successfully: ');
if process.success_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Parameters have been modified since last successful run: ');
if process.procChanged_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end
fprintf(1,'  Input has been updated by an upstream process: ');
if ~process.updated_, fprintf(1, 'yes\n'); else fprintf(1, 'no\n'); end


%% Graphical user interface

% Launch the graphical interface
uTrackPackageGUI(MD);

% Launch the graphical interface
packageGUI('TrackingPackage', MD);