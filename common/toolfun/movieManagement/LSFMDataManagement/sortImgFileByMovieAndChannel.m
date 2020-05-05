function newMovieWildcardPattern=sortImgFileByMovieAndChannel(movieWildcardPattern,varargin)
% Use a wildcare of type "/path/to/data/Cell{m}_channel{ch}*.tif" to build  folder per movie and a subfolder per channel data.
% Return a new wildcare describing the new data organization of the form "/path/to/data/movie_{m}/ch_{ch}/*.tif" 
% PR 2017
ip = inputParser;
ip.CaseSensitive = false;
ip.KeepUnmatched = true;
ip.addRequired('movieWildcardPattern', @(x)(iscell(x)||ischar(x)));
ip.addParameter('chStartIdx',1, @isnumeric);
ip.addParameter('movieStartIdx',1, @isnumeric);
ip.addParameter('channelDescriptor',[],@iscell); % Override chStartIdx, for channel c replace the {ch} by p.channelDescriptor{c}; 
ip.addParameter('movieDescriptor',[],@iscell); % Override movieStartIdx, for movie m replace the {m} by p.movieDescriptor{c}; 
ip.parse(movieWildcardPattern,varargin{:});
p=ip.Results;

newMovieWildcardPattern=movieWildcardPattern;
[fileDirRegexp,fileRegexp,ext]=fileparts(movieWildcardPattern);

channelDescriptor=p.channelDescriptor;
if(isempty(channelDescriptor))
    channelDescriptor=arrayfun(@(cIdx) num2str(cIdx),p.chStartIdx:10,'unif',0);
end

movieDescriptor=p.movieDescriptor;
if(isempty(movieDescriptor))
    movieDescriptor=arrayfun(@(cIdx) num2str(cIdx),p.movieStartIdx:100,'unif',0);
end

%% If the movies are not sorted by folder (the token is not present in a folder name)
if(hasToken(fileRegexp,'{m}')&&(~hasToken(fileDirRegexp,'{m}')))
    % Note: We choose a per directory and per movie Index rather than a per file method to avoid strain on the NFS. 

    % Compute from the wild card the set of movie directories that lead to at least one of those movies.
    allMatchingFile=rdir(buildWildCardPath(movieWildcardPattern,'*','*'));
    allMatchingFile={allMatchingFile.name};
    movieDirs=unique(cellfun(@(f) fileparts(f),allMatchingFile,'unif',0));

    % Build a folder per movie in each of those directories
    for dIdx=1:length(movieDirs)
        mIdx=1;
        [folderWildcard,fileWildCard,ext]=fileparts(buildWildCardPath(movieWildcardPattern,'*',movieDescriptor{mIdx}));
        movieFiles=rdir(fullfile(movieDirs{dIdx},[fileWildCard ext]));
        while ~isempty(movieFiles) % while there is movies, create folder and move associated data
            movieDir=sprintfPath([movieDirs{dIdx} filesep 'movie_%d'],mIdx);
            mkdirRobust(movieDir);
            for fIdx=1:length(movieFiles)
                movefile(movieFiles(fIdx).name,movieDir);
            end
            mIdx=mIdx+1;
            [folderWildcard,fileWildCard,ext]=fileparts(buildWildCardPath(movieWildcardPattern,'*',movieDescriptor{mIdx}));
            movieFiles=rdir(fullfile(movieDirs{dIdx},[fileWildCard ext]));
        end
    end
    newMovieWildcardPattern=[fileDirRegexp filesep 'movie_{m}' filesep fileRegexp ext];
end


%% If channel are not sorted by folder (the token is not present in a folder name)
if(hasToken(fileRegexp,'{ch}')&&(~hasToken(fileDirRegexp,'{ch}')))
    % At this point every folder only contain the channel associated to a single movie.
    allMatchingFile=rdir(buildWildCardPath(newMovieWildcardPattern,'*','*'));
    allMatchingFile={allMatchingFile.name};
    movieDirs=unique(cellfun(@(f) fileparts(f),allMatchingFile,'unif',0));
    
    % Build a folder per movie in each of those directories
    for dIdx=1:length(movieDirs)
        movieDir=movieDirs{dIdx};
        cIdx=1;
        [folderWildcard,fileWildCard,ext]=fileparts(buildWildCardPath(newMovieWildcardPattern,channelDescriptor{cIdx},'*'));
        fullfile(movieDir,[fileWildCard ext]);
        channelFiles=rdir(fullfile(movieDir,[fileWildCard ext]));
            while ~isempty(channelFiles) % While there is channel data to move
                chDir=sprintfPath([movieDir filesep 'ch_%d'],cIdx);
                mkdirRobust(chDir);
                for fIdx=1:length(channelFiles)
                    movefile(channelFiles(fIdx).name,chDir);
                end
                cIdx=cIdx+1;
                [folderWildcard,fileWildCard,ext]=fileparts(buildWildCardPath(newMovieWildcardPattern,channelDescriptor{min(cIdx,length(channelDescriptor))},'*'));
                channelFiles=rdir(fullfile(movieDir,[fileWildCard ext]));
            end
    end
    newMovieWildcardPattern=[fileDirRegexp filesep 'movie_{m}' filesep 'ch_{ch}' filesep fileRegexp ext];
end

function wildcardPath=buildWildCardPath(tokenPattern,chIdxOrPattern,movieIdxOrPattern)
    if(isnumeric(chIdxOrPattern))
        wildcardPath=strrep(tokenPattern,'{ch}',num2str(chIdxOrPattern));
    else
        wildcardPath=strrep(tokenPattern,'{ch}',chIdxOrPattern);
    end
    if(isnumeric(movieIdxOrPattern))
        wildcardPath=strrep(wildcardPath,'{m}',num2str(movieIdxOrPattern));
    else
        wildcardPath=strrep(wildcardPath,'{m}',movieIdxOrPattern);
    end

function res=hasToken(filename,token)
    res=~isempty(strfind(filename,token));
