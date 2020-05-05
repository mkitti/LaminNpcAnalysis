function processRenderArray=printProcMIPArray(processCellArray,savePath,varargin)
%% MIPSize: 
%% 
ip = inputParser;
ip.KeepUnmatched = true;
ip.addRequired('processCellArray',(@(pr) isa(pr,'cell')&&(ndims(pr)==2)));
ip.addRequired('savePath',@ischar);
ip.addParamValue('maxWidth',1600,@isnumeric);
ip.addParamValue('maxHeight',1000,@isnumeric);
ip.addParamValue('MIPSize',400,(@(x) isnumeric(x)||strcmp(x,'auto'))); % Max size of each rendering. If set to Auto, use the array arrangement of processCellArray and maxWidth/maxHeight to define Size.
ip.addParamValue('MIParrangement','auto',(@(x) strcmp(x,'useMap')||strcmp(x,'auto'))); % If set to auto use the MIPSize. Otherwise use the array arrangement of processCellArray.
ip.addParamValue('forceSize',false,@islogical);
ip.addParamValue('forceWidth',false,@islogical);
ip.addParamValue('forceHeight',false,@islogical);
ip.addParamValue('invertLUT',0,@islogical);
ip.addParamValue('saveVideo',true,@islogical)
ip.addParamValue('printFrame',[],@isnumeric);
ip.parse(processCellArray,savePath,varargin{:});
p=ip.Results;

MIPSize=p.MIPSize;
nProcess=numel(processCellArray);

frameNb=nan(1,nProcess);
for pIdx=1:nProcess
    if(~isempty(processCellArray{pIdx}))
            %% Handling the previous versions of processes before encapsulations...
            if(isa(processCellArray{pIdx},'ExternalProcess'))
                processProj=processCellArray{pIdx};
                if(isa(processProj,'ExternalProcess'))
                  processProjDynROI=ProjectDynROIProcess(processProj.owner_);
                  processProjDynROI.importFromDeprecatedExternalProcess(processProj);
                  try % Handle Project1D/ProjDyn different outFilePaths_spec (need to be defined through a class...)
                    projData=load(processProj.outFilePaths_{projDataIdx},'minXBorder', 'maxXBorder','minYBorder','maxYBorder','minZBorder','maxZBorder','frameNb');
                  catch
                    projDataIdx=4;
                  end
                  projData=load(processProj.outFilePaths_{projDataIdx},'minXBorder', 'maxXBorder','minYBorder','maxYBorder','minZBorder','maxZBorder','frameNb');
                  processProjDynROI.setBoundingBox( [projData.minZBorder projData.maxZBorder], [projData.minZBorder projData.maxZBorder], [projData.minZBorder projData.maxZBorder]);
                  processCellArray{pIdx}=processProjDynROI;
                end

            end
            if(isa(processCellArray{pIdx},'ProjectDynROIProcess'))
                processCellArray{pIdx}=ProjAnimation(processCellArray{pIdx},'ortho');
            end
            frameNb(pIdx)=processCellArray{pIdx}.getFrameNb();
            try
                if(length(processCellArray{pIdx}.outFilePaths_)>1)
                    frameNb(pIdx)=1;
                end
            catch
            end
    else
        frameNb(pIdx)=0;
    end
end



% set parameters
stripeSize = 8; % the width of the stripes in the image that combines all three maximum intensity projections
%the stripe color, a number between 0 (black) and 1 (white).  (If you're not using all of the bit depth then white might be much lower than 1, and black might be higher than 0.)
% if(p.invertLUT); 
%     stripeColor = 1; 
% else
    stripeColor = 200; 
% end;

% Build a (non-optimal) array arrangment for movie location that will fit
% the maximum video size.


MDArray=1:nProcess;
MDArray=reshape(MDArray,size(processCellArray,1),size(processCellArray,2));
MIPSize=p.MIPSize;
if(strcmp(p.MIPSize,'auto'))
    maxMIPSize=[(p.maxHeight-(size(MDArray,1)-1)*stripeSize)/size(MDArray,1) ,(p.maxWidth-(size(MDArray,2)-1)*stripeSize)/size(MDArray,2)];
else % Only compute arragnement if MIPSize is specified.
    if(strcmp(p.MIParrangement,'auto'))
        maxMoviePerLine=floor(p.maxWidth/(MIPSize+stripeSize));
        MDArray=(1:nProcess);
        untruncatedArraySize=[ceil(nProcess/maxMoviePerLine), min(nProcess,maxMoviePerLine)];
        if(untruncatedArraySize(1)*untruncatedArraySize(2)>nProcess)
            MDArray(untruncatedArraySize(1)*untruncatedArraySize(2))=0;
        end
        MDArray=reshape(MDArray,fliplr(untruncatedArraySize))'
    end
    maxMIPSize=[MIPSize MIPSize];
end
printFrame=[];
if(isempty(p.printFrame))
    printFrame=1:max(frameNb);
else
    printFrame=p.printFrame;
end

unprintedMovieIdx=0;

% Tile movie together according to MDArray, resize and adjust according to maxSize.
resAnimation=CachedAnimation(savePath,length(printFrame))

for frameIdx=printFrame
    maxXY=[];
    for i=1:size(MDArray,1)
        movieLine=[];
        for MDIdx=MDArray(i,MDArray(i,:)>0)
            mMaxXY=[];
            if(~isempty(processCellArray{MDIdx}))
                mMaxXY=processCellArray{MDIdx}.loadView(min(frameNb(MDIdx),frameIdx));
%               mMaxXY=imresize(mMaxXY,MIPSize/max(size(mMaxXY)),'nearest');
                if(p.forceHeight)
                    mMaxXY=imresize(mMaxXY,(maxMIPSize(1)/(size(mMaxXY,1))));
                else
                    if(size(mMaxXY,1)>size(mMaxXY,2))
                        mMaxXY=imresize(mMaxXY,maxMIPSize(1)/(size(mMaxXY,1)));
                    else
                        mMaxXY=imresize(mMaxXY,maxMIPSize(2)/(size(mMaxXY,2)));
                    end
                end
                
                % Enforce image width
                pad=maxMIPSize(2)-size(mMaxXY,2);
                mMaxXY=padarray(mMaxXY,[0 max(0,floor(pad/2))],'pre');
                mMaxXY=padarray(mMaxXY,[0 max(0,floor(pad/2)+mod(pad,2))],'post');

                    

                % Pad image vertically of the current line
                if isempty(movieLine)||((size(movieLine,1)-size(mMaxXY,1))>0)
                    pad=(size(movieLine,1)-size(mMaxXY,1));
                    mMaxXY=padarray(mMaxXY,[max(0,floor(pad/2)) 0],'pre');
                    mMaxXY=padarray(mMaxXY,[max(0,floor(pad/2)+mod(pad,2)) 0],'post');
                else
                    pad=(size(mMaxXY,1)-size(movieLine,1));
                    movieLine=padarray(movieLine,[max(0,floor(pad/2)) 0],'pre');
                    movieLine=padarray(movieLine,[max(0,floor(pad/2)+mod(pad,2)) 0],'post');
                end
            else
                %mMaxXY=zeros(size(movieLine,1),MIPSize,size(movieLine,3));
            end
            if(isempty(movieLine))
                movieLine=mMaxXY;
            else
                movieLine=[movieLine stripeColor*ones(size(movieLine,1),stripeSize,size(movieLine,3)) mMaxXY];
            end
        end

        %% Pad line or image horizontally
        if(isempty(maxXY)||(size(maxXY,2)>size(movieLine,2)))
            movieLine=padarray(movieLine,[0 max(0,((size(maxXY,2)-size(movieLine,2))))],'post');
        else
            maxXY=padarray(maxXY,[0 ((size(movieLine,2)-size(maxXY,2)))],'post');
        end

        %% Add movieline if the image remain within limits 
        if((size(maxXY,1)+stripeSize+size(movieLine,1))<p.maxHeight)

            if(isempty(maxXY))
                maxXY=movieLine;
            else
                maxXY=[maxXY; stripeColor*ones(stripeSize,size(movieLine,2),size(movieLine,3)); movieLine];
            end

        else
            unprintedMovieIdx=MDIdx;
            break;
        end
    end


    if(p.invertLUT)
        maxXY = imcomplement(maxXY);
    end
    resAnimation.saveView(frameIdx,maxXY);

    % imwrite((maxXY), [savePath filesep 'arrayFrame' filesep 'arrayFrame_' num2str(frameIdx,'%04d') '.png' ], 'Compression', 'none');   
    % imwrite((maxXY), [savePath filesep 'arrayFrame' filesep 'arrayFrame_' num2str(frameIdx,'%04d') '.tif' ], 'Compression', 'none');   

end
processRenderArray=resAnimation;
