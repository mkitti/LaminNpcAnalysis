%[fileList] = findFilesInSubDirs(topdir, filename) Finds all files containing 'filename' in their name in all subdirectories of 'topdir'.

% Francois Aguet, November 21, 2010

function fileList = findFilesInSubDirs(topdir, filename)

dirs = getSubDirs(topdir);
dirs{end+1} = topdir;

fileList = cell(1,length(dirs));
for k = 1:length(dirs)
    tt = dir([dirs{k} filesep '*' filename '*']);
    if ~isempty(tt)
        fileList{k} = arrayfun(@(x) [dirs{k} filesep x.name], tt, 'UniformOutput', false);
    end
end

fileList = vertcat(fileList{:});