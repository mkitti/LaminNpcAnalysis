%[outdatedList] = listOutdatedMEX(rpath) returns a list of all outdated MEX files
% SVN time stamps (commit) of C/C++ files are used as a reference.
%
% Inputs: 
%         rpath: path from which to start search. Function is recursive.

% Francois Aguet, 03/26/2013

function outdatedList = listOutdatedMEX(rpath, spath)
outdatedList = [];

if nargin<2
    spath = '';
end
cpath = [rpath spath];

flist = dir(cpath);
%remove invisible dirs
flist(arrayfun(@(i) strcmp(i.name(1), '.'), flist)) = [];


dlist = flist([flist.isdir]==1); % -> recursive call
flist = flist([flist.isdir]==0);

% identify C/C++ files
fileNames = arrayfun(@(i) i.name, flist, 'unif', 0);
cfiles = regexpi(fileNames, '.*\.c.*', 'match', 'once');
cfiles(cellfun(@isempty, cfiles)) = [];
nc = numel(cfiles);

if nc~=0
    svnDateFormat = '\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d';
    
    % get dates of commit
    cdate = zeros(1,nc);
    for k = 1:nc
        cmd = ['svn info ' cpath cfiles{k} ' | grep "Text Last Updated"'];
        [st,tmp] = system(cmd);
        if st==0
            cdate(k) = datenum(regexpi(tmp, svnDateFormat, 'match', 'once'), 'yyyy-mm-dd HH:MM:SS');
        end
    end
    
    ext = {'mexmaci64', 'mexa64', 'mexw64'};
    
    for k = 1:nc
        fname = regexpi(cfiles{k}, '.*(?=\.c)', 'match', 'once');
        mexnames = cellfun(@(i) [fname '.' i], ext, 'unif', 0);
        % add uncompiled files
        [ucList,  ucIdx] = setdiff(mexnames, fileNames);
        if numel(ucIdx)~=3
            outdatedList = [outdatedList; cellfun(@(i) [spath i], ucList', 'unif', 0)]; %#ok<AGROW>
        end        
        mexnames(ucIdx) = [];
        nm = numel(mexnames);
        mdate = zeros(1,nm);
        for m = 1:nm
            cmd = ['svn info ' cpath mexnames{m} ' | grep "Text Last Updated"'];
            [st,tmp] = system(cmd);
            if st==0
                mdate(m) = datenum(regexpi(tmp, svnDateFormat, 'match', 'once'), 'yyyy-mm-dd HH:MM:SS');
            end
        end
        outdatedList = [outdatedList; cellfun(@(i) [spath i], mexnames(mdate<cdate(k))', 'unif', 0)]; %#ok<AGROW>
    end
end

if ~isempty(dlist)
    dlist = arrayfun(@(i) listOutdatedMEX([rpath filesep], [spath i.name filesep]), dlist, 'unif', 0);
    dlist(cellfun(@isempty, dlist)) = [];
    outdatedList = [outdatedList; vertcat(dlist{:})];
end
