%[subdirs] = getSubDirs(topdir) Returns a list of subdirectories from 'topDir'

% Francois Aguet, November 21, 2010

function subdirs = getSubDirs(topdir)
if strcmp(topdir(end), filesep)
    topdir = topdir(1:end-1);
end

cdirs = dirList(topdir);
ndirs = length(cdirs);
dirStruct = cell(ndirs,1);
for k = 1:ndirs;
    dirStruct{k} = [topdir filesep cdirs(k).name];
end

subdirs{1} = dirStruct;

tt = cellfun(@(x) arrayfun(@(y) [x filesep y.name], dirList(x), 'UniformOutput', false), subdirs{1}, 'UniformOutput', false);
tt = vertcat(tt{:});
count = 1;
while ~isempty(tt)
    count = count+1;
    subdirs{count} = tt;
    tt = cellfun(@(x) arrayfun(@(y) [x filesep y.name], dirList(x), 'UniformOutput', false), subdirs{count}, 'UniformOutput', false);
    tt = vertcat(tt{:});
end

subdirs = vertcat(subdirs{:});