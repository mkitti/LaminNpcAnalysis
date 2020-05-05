%% ROI set-up via Command line


%% Initialization

% dvPath = '~/Desktop/2014Mar26/Actin-TM2.ome.tif';
% MD = MovieData(dvPath);
% fprintf(1, 'Object saved under: %s\n', MD.getFullPath());
% fprintf(1, 'Output directory for analysis: %s\n', MD.outputDirectory_);

init_moviedata;

%% Create top-level analysis

MD.reset()
MD.addPackage(SegmentationPackage(MD));
MD.getPackage(1).createDefaultProcess(1);
MD.getPackage(1).createDefaultProcess(2);

%% ROI Creation
% can we depend on imSize_ being not empty
fullMask = true(MD.imSize_);

% Create ROI mask
roi1Mask = fullMask;
roi1Mask(:, 1:end/2) = false;

% Save ROI mask Path
roi1Path = fullfile(MD.getPath(), 'roi1');
if ~isdir(roi1Path), mkdir(roi1Path); end
roi1MaskPath = fullfile(roi1Path, 'mask.tif');
imwrite(roi1Mask, roi1MaskPath);

% Create a first region of interest
MD.addROI(roi1MaskPath, roi1Path);
MD.getROI(1).setPath(roi1Path);
MD.getROI(1).setFilename('roi1.mat');

% Save the movie graph (main movie + region of interest)
MD.save;

%% 

% Channels objects are shared between parent of ROIs
status = isequal(MD.getChannel(1), MD.getROI(1).getChannel(1));
disp(status);

% Owner of channels objects is the parent movie
status = isequal(MD.getROI(1).getChannel(1).owner_, MD);
disp(status);

% Analysis objects created prior to ROI creation are shared
disp(isequal(MD.getPackage(1), MD.getROI(1).getPackage(1)));
disp(isequal(MD.getPackage(1).getProcess(1),...
    MD.getROI(1).getPackage(1).getProcess(1)));

%%

% Create ROI-specific analysis package
MD.getROI(1).addPackage(WindowingPackage(MD.getROI(1)));

% Package is created / associated with the ROI
disp(MD.getROI(1).getPackageIndex('WindowingPackage'));

% Newly created package is not associated with the parent movie
disp(MD.getPackageIndex('WindowingPackage'));