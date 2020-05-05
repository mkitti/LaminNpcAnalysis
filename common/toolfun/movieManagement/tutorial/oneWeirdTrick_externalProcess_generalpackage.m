% This example is meant to demonstrate the use of ExternalProcess and
% GenericPackage. These two classes are meant to allow the developer to
% quickly take advantage of the Process and Package APIs while prototyping
% an arbitrary function. In particular, with just a few commands, the
% Package GUI routines are made accessible.
%
% Below we combine a fully developed Process, ThresholdProcess, with a
% prototype process that says "Hello world!" into a GenericPackage. We then
% show the Package GUI where the the Processes can be configured and run.
%
% Author(s)
% Andrew Jamieson
% Mark Kittisopikul
% March 2017

%% Configuration
% config.imageData = 'example.tif';
config.imageData = which('cameraman.tif');

%% Load arbitrary image dataset
MD = MovieData.load(config.imageData);

%% Create and configure processes
% ThresholdProcess is a predefined, developed process with default
% parameters
threshProc = ThresholdProcess(MD);

% ExternalProcess is used to prototype our Hello World function
extProc = ExternalProcess(MD,'Say something',@(p) disp(p.getParameters().text));
% ExternalProcess uses a struct with no fields as a default
% Thus, we need to set the parameters with the field text
extProc.setParameters(struct('text','Hello world!'));

%% Add Processes and setup to MovieData object
MD.addProcess(threshProc);
MD.addProcess(extProc);
% This creates a GenericPackage with all the Processes contained in MD
% However, you can also give an arbitrary set of Processes
MD.addPackage(GenericPackage(MD));


% Alternatively, you can create the GenericPackage via a list of processes 
% to specify a subset of interest
MD.addPackage(GenericPackage({threshProc; extProc}))
% or like this: MD.addPackage(GenericPackage({MD.processes_{1}; MD.processes_{2}}))

% You may also want to configure the dependency matrix
% openvar('MD.packages_{1}.dependencyMatrix_')
% Assign a name
MD.packages_{1}.name_ = 'Hello World';
MD.packages_{2}.name_ = 'Hello World v2';


%% Show GUI
h = MD.packages_{1}.GUI(MD);
% Alternatively, and with support for multiple GenericPackges use
% MD.packages_{1}.showGUI()
disp('');
disp('Push any key to continue the demo');
disp('');
pause;
if(isvalid(h))
    close(h);
end

%% Extended ExternalProcess customization
% This was not part of the original demo set.
% This section demonstrates how to generate image, overlay, and graph
% outputs for movieViewer.

% Make sure Processes were run
cellfun(@run,MD.processes_);
% Just return an the parameter text when output is requested
MD.processes_{2}.loadChannelOutputFcn_ = @(proc,iChan,iFrame,varargin) proc.getParameters().text;

% Keep the default drawableOutput, but have formatData just return zeros
MD.processes_{2}.drawableOutput_(1).formatData = @(x) zeros(MD.imSize_);

% The second drawable output is just text
MD.processes_{2}.drawableOutput_(2).name = 'Hello World';
MD.processes_{2}.drawableOutput_(2).var = 'text';
% We need to format the output from loadChannelOutput for TextDisplay below
MD.processes_{2}.drawableOutput_(2).formatData = @(txt) struct('String',{{txt}},'Color',[1 0 0],'Position',[10 10]);
% The types are image, overlay, and graph
MD.processes_{2}.drawableOutput_(2).type = 'overlay';
% Use the command "help movieManagement/display" for options
MD.processes_{2}.drawableOutput_(2).defaultDisplayMethod = @TextDisplay;

% Setup third drawable output as a graph
hfig = figure('Visible','off');
graphLocation = [MD.outputDirectory_ filesep 'test.fig'];
plot(0:0.01:2,sin((0:0.01:2)*pi))
savefig(hfig,graphLocation)
close(hfig)

MD.processes_{2}.drawableOutput_(3).name = 'Sin Graph';
MD.processes_{2}.drawableOutput_(3).var = 'sin';
MD.processes_{2}.drawableOutput_(3).formatData = @(varargin) graphLocation;
MD.processes_{2}.drawableOutput_(3).type = 'graph';
MD.processes_{2}.drawableOutput_(3).defaultDisplayMethod = @FigFileDisplay;

%% Show movieViewer GUI as if you pushed the Results button
movieViewer(MD,'procID',2);