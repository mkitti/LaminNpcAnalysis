function duplicateList = checkDuplicateFiles(matlabHome,checkRoot,omitQu)
%CHECKDUPLICATEFILES checks for duplicate files in MATLAB-HOME
%
% SYNOPSIS: duplicateList = checkDuplicateFiles(matlabHome,checkRoot)
%
% INPUT matlabHome (optional): Directory (including subdirs) of functions
%                   you want to check for overlap. Default (MATLAB)HOME
%       checkRoot (optional): also check for overlap with Mathworks
%                   functions. Default: 0
%       omitQu (optional) : do not list duplicates between matlabHome and
%                   Aaron Ponti's Qu2 package. Default: 0
%   
%        
%
% OUTPUT duplicateList: n-by-2 cell array with {fileName, pathName}
%                       or n-by-1 cell array with full path if checkRoot
%
% REMARKS This is a bit of a hack
%
% created with MATLAB ver.: 7.5.0.342 (R2007b) on Windows_NT
%
% created by: Jonas Dorn
% DATE: 30-Nov-2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CHECK INPUT

duplicateList = cell(0,2);

if nargin == 0 || isempty(matlabHome)
    % check for MATLABHOME, HOME
    matlabHome = getenv('MATLABHOME');
    if isempty(matlabHome)
        % lccb-compatibility
        matlabHome = getenv('HOME');
    end
    if isempty(matlabHome)
        % warn
        warning('(MATLAB)HOME is not defined. Supply path')
        return
    end
    matlabHome = fullfile(matlabHome,'matlab');
end

if nargin < 2 || isempty(checkRoot)
    checkRoot = false;
end
if nargin < 3 || isempty(omitQu)
    omitQu = false;
end

%% find duplicate m-files

% get files
lof = searchFiles('\.m$','',matlabHome);


% remove @, remove contents.m, remove private functions
for i = length(lof):-1:1,
    if any(findstr(lof{i,2},'@')) || strcmpi(lof{i,2},'private') ...
            || strcmpi(lof{i,1},'contents.m') || ...
            (omitQu && any(findstr(lof{i,2},'qu2')))
        lof(i,:)=[];
    end,
end

if checkRoot
    % check all files also against matlab files. Add to duplicateList only
    % if there is more than one hit for each fileName. Of course, this
    % means that we have to run unique in the end
    nFiles = size(lof,1);
    duplicateList = cell(3*nFiles,1); % that should be sufficient
    ct = 1;
    
    for i=1:nFiles
        s = which(lof{i,1},'-all');
        ns = length(s);
        % remove private, @
        for is = ns:-1:1
            if any(findstr(s{is},'@')) || any(findstr(s{is},'private')) || any(findstr(s{is},'qu2'))
                s(is)=[];
            end
        end
        ns = length(s);
        if ns > 1
            duplicateList(ct:ct+ns-1) = s;
            ct = ct + ns;
        end
        
    end
    % remove empties
    duplicateList(ct:end) = [];
    % remove duplicates
    duplicateList = unique(duplicateList);
    
    % split and sort for ease-of-use
    tmp = duplicateList;
    duplicateList = cell(length(duplicateList),2);
    for d = 1:length(tmp)
        [pname,fname,ext] = fileparts(tmp{d});
        if isempty(pname)
            % someone managed to overload a builtin
            duplicateList{d,2} = tmp{d};
        else
            duplicateList{d,1} = pname;
            duplicateList{d,2} = [fname,ext];
        end
    end
    % sort for easier readability
    fn = strvcat(duplicateList{:,2});
    [dummy,idx] = sortrows(fn);
    duplicateList = duplicateList(idx,:);
    
else
    % find unique filenames
    names=strvcat(lof{:,1});
    [un,m,n]=unique(names,'rows');
    [num,ue]=getMultiplicity(n);
    
    % check for duplicates
    idx=find(num>1);
    for ii=idx',
        duplicateList = [duplicateList;lof(n==ue(ii),:)];
    end
end