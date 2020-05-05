function processRenderArray=printMIPArray(ML,varargin)
% Print an array of XY MIP for all Movie in the MovieList. The resulting
% images and movies are saved in the movieList output directory.

ip = inputParser;
ip.KeepUnmatched = true;
ip.addRequired('ML',@(MD) isa(ML,'MovieList'));
ip.addParamValue('maxWidth',1600,@isnumeric);
ip.addParamValue('maxHeight',1200,@isnumeric);
ip.addParamValue('MIPSize','auto'); % See printProcMIPArray doc
ip.addParamValue('forceComputeMIP',false); % See printProcMIPArray doc
ip.addParamValue('invertLUT',0,@islogical);
ip.addParamValue('savePath',[ML.outputDirectory_ filesep],@ischar);
ip.addParamValue('separateVideo',false,@islogical);
ip.addParamValue('name',[],@ischar);
ip.parse(ML,varargin{:});
p=ip.Results;
% turn a specific warning off
warning('off', 'MATLAB:imagesci:tifftagsread:expectedAsciiDataFormat');

name=p.name;
if(isempty(p.name))
    name='MIPArray';
end

savePath=[p.savePath '-' name];

if(isempty(ML.movies_))
    disp('No movies found, trying sanity check');
    ML.sanityCheck()
end

if(isempty(ML.movies_))
    disp('No movies found, abort');
    return;
end

% collect or run mipping
processList=cell(1,ML.getSize());
movieCell=ML.getMovies();
for MDIdx=1:length(movieCell)
    MD=movieCell{MDIdx};
    procIdx=[];
    try
         procIdx=MD.findProcessTag('printMIP');
    catch 
    end;
    if(isempty(procIdx)||p.forceComputeMIP)
        procIdx=printMIP(MD,'renderType','sideBySide');
    end

    processList{MDIdx}=procIdx;   
end

if(p.separateVideo)
    for MDIdx=1:length(movieCell)
        pr=ProjAnimation(processList{MDIdx},'ortho');
        if(processList{MDIdx}.getFrameNb()>1)
            pr.saveVideo([p.savePath 'movie-' num2str(MDIdx) '-mip.avi']);
        else
            animationSwap=ImAnimation.buildFromCache(pr,[p.savePath 'movie-' num2str(MDIdx) '-mip']);
        end
        processList{MDIdx}.swapCache();
    end
else
    processRenderArray=printProcMIPArrayCellBased(processList,savePath,varargin{:});
    if(processRenderArray.getFrameNb()>1)
        processRenderArray.saveVideo([savePath filesep 'mipArray.avi']);
        animationSwap=ImAnimation.buildFromCache(processRenderArray);
    else
        animationSwap=ImAnimation.buildFromCache(processRenderArray,[p.savePath 'mip-array']);
    end
end


