function [processRenderer,orthoProj,renderCell,cachedAnim]=printMIP(MD,varargin)
% Title says it all -- PR, augmented from Meghan D. 2015

ip = inputParser;
ip.addRequired('MD',@(MD) isa(MD,'MovieData'));
ip.addOptional('processProjection',[],@(p) isa(p,'ProjectDynROIProcess')); % modular backend for projections storing (RAM, NFS etc ...)
ip.addParameter('renderType','sideBySide'); 
ip.addParameter('mipFrame',1:MD.nFrames_); 
ip.addParameter('histAdjust','none'); 
ip.addParameter('size',[]); 
ip.parse(MD,varargin{:});
p=ip.Results;

process=[];
%progressText(0,'Print MIP');

% turn a specific warning off
warning('off', 'MATLAB:imagesci:tifftagsread:expectedAsciiDataFormat');

if(MD.zSize_==1)
    warning('This seems to be a 2D movie, No MIP produced.');
    return;
end


% MD.addProcess(processRenderer);

ZXRatio=MD.pixelSizeZ_/MD.pixelSize_;
minIntensityNorm=[];
maxIntensityNorm=[];
for chIdx=1:length(MD.channels_)
    vol=MD.getChannel(chIdx).loadStack(1);
    minIntensityNorm=[ minIntensityNorm min(vol(:))];
    maxIntensityNorm=[ maxIntensityNorm max(vol(:))];
end

    
nFrame=length(p.mipFrame);
renderCell=cell(nFrame,1);
nZ=MD.zSize_;

allProj=cell(nFrame,4,length(MD.channels_));

for chIdx=1:numel(MD.channels_)

    oChannel=MD.getChannel(chIdx);
    parfor fIdx=1:nFrame
        %     progressText(frameIdx/nFrame,'Print MIP');
        frameIdx=p.mipFrame(fIdx);
        % stackFrameReader=stackReaders{fIdx};
        oChannel.getReader()
        vol=oChannel.loadStack(fIdx);

        %% Their is no rendering at this point. we would need a small rendering interface for two frames.
        proj=cell(1,4);
        [proj{1},proj{2},proj{3},proj{4}]=computeMIPs(vol,ZXRatio,minIntensityNorm(chIdx),maxIntensityNorm(chIdx)); 
        switch p.histAdjust
        case 'imadjust'
            proj{1}=imadjust(proj{1});
            proj{4}=imadjust(proj{4}); 
        case 'adapthisteq'
            proj{1}=adapthisteq(proj{1});
            proj{4}=adapthisteq(proj{4}); 
        case 'localcontrast'
            proj{1}=localcontrast(proj{1});
            proj{4}=localcontrast(proj{4});
        case 'locallapfilt'
            proj{1}= locallapfilt(proj{1},0.8,0.5,1);
            proj{4}= locallapfilt(proj{4},0.8,0.5,1);
        case 'none'
        end
        allProj(fIdx,:,chIdx)=proj(:);
    end
end

parfor fIdx=1:nFrame
    proj=squeeze(allProj(fIdx,:,:));
    if(strcmp(p.renderType,'fused'))
        if((length(MD.channels_)==1))
            renderedProj=cellfun(@(p) uint8(255*sc(imcomplement(p))),proj,'unif',0);
        end

        if((length(MD.channels_)==2))
            renderedProj=arrayfun(@(p) uint8(255*sc(cat(3,proj{p,:}),'stereo')),1:4,'unif',0);
        end

        if((length(MD.channels_)>2))
            renderedProj=arrayfun(@(p) uint8(255*sc(cat(3,proj{p,:}),'compress')),1:4,'unif',0);
        end

    else
        if(numel(MD.channels_)>1)
            renderedProj=arrayfun(@(p) repmat([proj{p,:}],[1 1 3]),1:4,'unif',0);
        else
            renderedProj=arrayfun(@(p) repmat([proj{p}],[1 1 3]),1:4,'unif',0);
        end
    end
    renderCell{fIdx}=renderedProj;
end



%% Save in a cache
processProjection=p.processProjection;
if(isempty(processProjection))
    % The logic below is useless at the point, but further change should use 
    % the first object for  pixel projection and the second one for rendering.
    processProjection=CachedProjectDynROIProcess(MD,'','nFrames',nFrame); % projection encapsulator
end
processRenderer=ProjectDynROIRendering(processProjection,'MIP'); % Rendering encapsulator 
processRenderer.setProcessTag('printMIP');
for frameIdx=1:nFrame
    processRenderer.saveFrame(1,frameIdx,renderCell{frameIdx}{1},renderCell{frameIdx}{2},renderCell{frameIdx}{3},renderCell{frameIdx}{4})
end

oldProcess=MD.searchProcessTag('printMIP');
if(isempty(oldProcess))
    MD.addProcess(processRenderer);
else
    MD.replaceProcess(oldProcess,processRenderer);
end

cachedAnim=processRenderer.cachedOrtho;

%% Save in NFS to respect older specs.
% processRenderer=processProjection.renderFused();
orthoProj=ImAnimation.buildFromCache(ProjAnimation(processRenderer,'ortho'),[MD.outputDirectory_ filesep 'MIP' filesep 'ortho' filesep]);
orthoProj.saveVideo([MD.outputDirectory_ filesep 'MIP' filesep 'ortho.avi']);
ImAnimation.buildFromCache(ProjAnimation(processRenderer,'XY'),[MD.outputDirectory_ filesep 'MIP' filesep 'XY' filesep]);
ImAnimation.buildFromCache(ProjAnimation(processRenderer,'ZY'),[MD.outputDirectory_ filesep 'MIP' filesep 'ZY' filesep]);
ImAnimation.buildFromCache(ProjAnimation(processRenderer,'ZX'),[MD.outputDirectory_ filesep 'MIP' filesep 'ZX' filesep  ]);
processRenderer.swapCache();    
MD.save();



% video = VideoWriter([savePath filesep 'three.avi']);
% video.FrameRate = 4;  % Default 30
% video.Quality = 90;    % Default 75

% open(video)
% for frameIdx=1:MD.nFrames_
%     % save the maximum intensity projections
%     three=imread(sprintfPath(ThreeFilesPattern,frameIdx));
%     writeVideo(video,three)
% %     fprintf('\b|\n');
% end
% close(video)

% if(~isempty(p.processRenderer))
%     p.processRenderer.saveFrame(1,fIdx,XYProj,ZYProj,ZXProj);
% end




