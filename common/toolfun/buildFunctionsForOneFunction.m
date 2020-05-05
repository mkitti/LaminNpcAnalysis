function []=buildFunctionsForOneFunction(funName)
% function []=buildFunctionFromRepository(funName) obtains all the
% functions required for running the function 'funName' and exclude matlab
% builtin functions and store the function list into the use defined folder
% Sangyoon Han April 2016

% Ask for the output directory if not supplied
outDir = uigetdir(pwd,'Select output directory:');

%Get all the function dependencies and display toolboxes
[packageFuns, toolboxesUsed] = getFunDependencies(funName,'/extern');
disp('The package uses the following toolboxes:')
disp(toolboxesUsed)

% Copy function files
nFiles = numel(packageFuns);
disp(['Copying all '  num2str(nFiles) ' files ...'])
for j = 1:nFiles
    copyfile(packageFuns{j},outDir);
end
