function buildPackage(varargin)
% Build the selected packages and export them to a given repository
%
% SYNOPSIS
%   buildPackage(packageList, outDir)
%   buildPackage('exclude', {'extern','myfunctions'})
%
% This function copies all the files needed to run the selected packages data
% processing package into a single folder for upload to the website. It
% assumes you have checked out all the files from the SVN repository, and
% that they are all in your matlab path.
%
% INPUT:
%
%   packageList - A package name or a cell array of package names. If not
%   input a prompt dialog will appear asking to select a list of packages.
%
%   outDir - Optional. The directory to copy all the package files to. If
%   not input
%
%   Parameter/value pairs.
%
%   exclude -  a string of a cell array of strings, giving a list of
%   patterns to exclude when looking for the function dependencies.
%   Default: extern.
%   slim:  -- default false , if true, excludes extras: bioformats, docs, icons.
%
%   also see: matlab.apputil.create
% Sebastien Besson, July 2011 (last modified: Nov 2012)

% Input check
ip = inputParser;
isClass = @(x) exist(x,'class')==8;
ip.addOptional('packageList',{},@(x) ischar(x) || iscell(x));
ip.addOptional('outDir','',@ischar);
ip.addParameter('exclude', {[]}, @(x) (ischar(x) || iscell(x)));
ip.addParameter('slim', false, @islogical);
ip.parse(varargin{:});

if isempty(ip.Results.packageList)
    % List available packages and additional files required for running them
    buildPackageList = {
        'BiosensorsPackage';...
        'QFSMPackage';...
        'SegmentationPackage';...
        'TrackingPackage';...
        'WindowingPackage'};
    validPackage = cellfun(isClass, buildPackageList);
    buildPackageList = buildPackageList(validPackage);
    if isempty(buildPackageList), error('No package found'); end
    
    % Create package names
    packageNames = cellfun(@(x) eval([x '.getName']),buildPackageList,'Unif',0);
    [packageNames,index]=sort(packageNames);
    buildPackageList=buildPackageList(index);
    
    % Ask the user which packages to build
    [packageIndx,status] = listdlg('PromptString','Select the package(s) to build:',...
        'SelectionMode','multiple','ListString',packageNames);
    if ~status, return; end
    packageList=buildPackageList(packageIndx);
else
    packageList = ip.Results.packageList;
end

% Ask for the output directory if not supplied
if isempty(ip.Results.outDir)
    outDir = uigetdir(pwd,'Select output directory:');
else
    outDir = ip.Results.outDir;
end

% Add legacy code to the package list for dependency search
legacyFunctions = getLegacyCode(packageList);

%Get all the function dependencies and display toolboxes
[packageFuns, toolboxesUsed] = getFunDependencies(...
    vertcat(packageList, legacyFunctions), ip.Results.exclude);
disp('The package uses the following toolboxes:')
disp(toolboxesUsed)
% toolboxesUsed is the just the list of names, see getFunDependencies
% disp({toolboxesUsed.Name;toolboxesUsed.Version}')
%% Additional files can be found under four types of format:
%   * GUIs may have associated *.fig
%   * Processes and GUIs may have associated *.pdf
%   * Mex-files have many extensions depending on the OS
%   * Icons or other MAT-files

% Split functions into paths, filenames and extensions for search
[packageFunsPaths, packageFunsNames, packageFunsExt]=...
    cellfun(@fileparts,packageFuns,'UniformOutput',false);

% Find associated documentation files
hasDocFile = cellfun(@(x,y) exist([x  '.pdf'],'file')==2,packageFunsNames);
packageDocs = cellfun(@(x) which([x  '.pdf']), packageFunsNames(hasDocFile),...
    'UniformOutput',false);

% Get GUI fig files
isGUIFile =logical(cellfun(@(x) exist([x(1:end-2) '.fig'],'file'),packageFuns));
packageFigs = cellfun(@(x) [x(1:end-2) '.fig'],packageFuns(isGUIFile),'UniformOutput',false);

% List all mex files in the package
mexFunsExt={'.dll';'.mexglx';'.mexmaci';'.mexmaci64';'.mexa64';'.mexw64'};
mexFunsIndx= find(ismember(packageFunsExt,mexFunsExt));
packageMexList=arrayfun(@(x)  dir([packageFunsPaths{x} filesep packageFunsNames{x} '.*']),...
    mexFunsIndx,'Unif',false);
packageMexFunsPaths=packageFunsPaths(mexFunsIndx);
packageMexFunsNames = @(x) strcat([packageMexFunsPaths{x} filesep],...
    {packageMexList{x}(~[packageMexList{x}.isdir]).name}');
packageMexFuns = arrayfun(@(x) packageMexFunsNames(x),1:numel(mexFunsIndx),'Unif',false);
packageMexFuns =vertcat(packageMexFuns{:});
packageFuns(mexFunsIndx) = [];

% Remove additional compilation files
if ~isempty(packageMexFuns)
    compFunsExt = {'.c';'.cpp';'.h';'.nb'}; % leave .m as help/documentation/backup if available
    for i=1:numel(compFunsExt)
        indx = ~cellfun(@isempty,regexp(packageMexFuns,[compFunsExt{i} '$'],'once'));
        packageMexFuns(indx)=[];
    end
end

% Check for .m files associated with mex files
% and remove these from packageFuns to avoid duplication.
if ~isempty(packageMexFuns)
    [mf1, mf2, mf3] = cellfun(@(x)fileparts(x), packageMexFuns, 'Unif', false);
    [f1, f2, f3] = cellfun(@(x)fileparts(x), packageFuns, 'Unif', false); 
    [Int, if2, iPack] = intersect(f2, mf2);
    packageFuns(if2) = [];
end


% Get the main path to the icons folder
iconsPath = fullfile(fileparts(which('packageGUI.m')),'icons');
icons = dir([iconsPath filesep '*.png']);
packageIcons = arrayfun(@(x) [iconsPath filesep x.name],icons,'Unif',false);


% Concatenate all matlab files but the documentation
packageFiles=vertcat(packageFuns,packageFigs);


% Handle namespace packages and class folders separately
filesep_token = filesep;
if(filesep_token == '\')
    filesep_token = '\\';
end
pattern = sprintf('(.*%s[\\+@].*)%s.*', filesep_token, filesep_token);
hasNs = ~cellfun(@isempty, regexp(packageFiles, pattern));
if any(hasNs)
    nsFiles = packageFiles(hasNs);
    packageFiles(hasNs) = [];
    tokens = regexp(nsFiles, pattern, 'tokens');
    nsDirs = unique(cellfun(@(x) x{1}{1},tokens, 'Unif',0));
else
    nsDirs = {};
end


% Also Handle functions from extern differently.
fromExtern = ~cellfun(@isempty, cellfun(@(x)strfind(x, [filesep 'extern' filesep]), packageFiles, 'Uniform', 0));
if any(fromExtern)
    
    packExtern = packageFiles(fromExtern);
    if ~(ip.Results.slim)
        exBF = cellfun(@isempty, cellfun(@(x) strfind(x, [filesep 'bioformats' filesep]), packageFiles(fromExtern),'Uniform', 0));
        packExternXBF = packExtern(exBF);
    else
        % if slim, we may need to include BF
        packExternXBF = packExtern; 
    end
    packageFiles(fromExtern) = [];
       
else
    packExternXBF = [];
end


%% Export package files
% Create package output directory if non-existing
disp('Creating release directory...')
if ~isdir(outDir), mkdir(outDir); end


% Copy function files
nFiles = numel(packageFiles);
disp(['Copying all '  num2str(nFiles) ' files ...'])
for j = 1:nFiles
    iLFS = max(regexp(packageFiles{j},filesep));
    copyfile(packageFiles{j},[outDir filesep packageFiles{j}(iLFS+1:end)]);
end

% Copy namespace packages and class folders
if ~isempty(nsDirs)
    nNsDirs = numel(nsDirs);
    disp(['Copying all package '  num2str(nNsDirs) ' files ...'])
    for j = 1:nNsDirs
        iLFS = max(regexp(nsDirs{j},filesep));
        copyfile(nsDirs{j},[outDir filesep nsDirs{j}(iLFS+1:end)]);
    end
end

if ~(ip.Results.slim)
    % Create icons output directory if non-existing
    disp('Creating icons directory...')
    iconsDir=[outDir filesep 'icons'];
    if ~isdir(iconsDir), mkdir(iconsDir); end
end

if ~(ip.Results.slim)
    % Copy icons
    nIcons = numel(packageIcons);
    disp(['Copying all '  num2str(nIcons) ' files ...'])
    for i = 1 : nIcons
        iLFS = max(regexp(packageIcons{i},filesep));
        copyfile(packageIcons{i}, [iconsDir filesep packageIcons{i}(iLFS+1:end)]);
    end
end


if ~(ip.Results.slim)
    % Create documentation output directory if non-existing
    disp('Creating documenation directory...')
    docDir=[outDir filesep 'doc'];
    if ~isdir(docDir), mkdir(docDir); end



    % Copy documentation
    nDocFiles = numel(packageDocs);
    disp(['Copying all '  num2str(nDocFiles) ' files ...'])
    for i = 1 : nDocFiles
        iLFS = max(regexp(packageDocs{i},filesep));
        copyfile(packageDocs{i}, [docDir filesep packageDocs{i}(iLFS+1:end)]);
    end

end

if ~isempty(packageMexFuns)
    % Create mex output directory if non-existing
    disp('Creating MEX-files directory...')
    mexDir=[outDir filesep 'mex'];
    if ~isdir(mexDir), mkdir(mexDir); end
    
    % Copy mex-files
    nMexFiles = numel(packageMexFuns);
    disp(['Copying all '  num2str(nMexFiles) ' MEX files ...'])
    for i = 1 : nMexFiles
        iLFS = max(regexp(packageMexFuns{i},filesep));
        copyfile(packageMexFuns{i},[mexDir filesep packageMexFuns{i}(iLFS+1:end)]);
    end
end

%% External libraries
disp('Creating external directory...')
externDir=[outDir filesep 'extern'];
if ~isdir(externDir), mkdir(externDir); end
if ~isempty(packExternXBF)
    % Copy function files
    nFiles = numel(packExternXBF);
    disp(['Copying all (extern) '  num2str(nFiles) ' files ...'])
    for j = 1:nFiles
        iLFS = max(regexp(packExternXBF{j},filesep));
        copyfile(packExternXBF{j},[outDir filesep 'extern' filesep  packExternXBF{j}(iLFS+1:end)]);
    end    
else
    
end


if ~(ip.Results.slim)
    % % Bio-Formats (Jar File)
    disp('Creating Bio-Formats directory...')
    bfSourceDir=fileparts(which('bfGetReader.m'));
    bfTargetDir=[outDir filesep 'bioformats'];
    copyfile(fullfile(bfSourceDir), bfTargetDir)

    disp(['Wrote package to ' outDir])
end

function legacyFunctions = getLegacyCode(packageList)

legacyFunctions = {};
if any(strcmp('TrackingPackage', packageList))
    legacyFunctions = {...
        'scriptDetectGeneral.m';
        'scriptTrackGeneral.m';...
        'overlayFeaturesMovie.m';...
        'overlayTracksMovieNew.m';...
        'plotTracks2D.m'};
end
