function render=printProjProcessArray(processCellArray,graphName,outputDirPlot,names,varargin)
% A projection tiling function that is annoyingly close to printProcMIPArray. 
% The main difference is that printProcMIPArray is designed to build video from a list of projection MIP
% while printProjProcessArray organize process in condition, rendering type and movies to automatically 
% compare rendering results.
% I would be much better to fuse both functions by augmenting printProcMIPArray to allow for various conditions and rendering type.
% <processCellArray> is a collection of rendering process grouped by
% - condition: cell(1,numel(<names>))
%    -  rendering type: cell(1,length(processCellArray{1}))
%           -  movies (array) array(1,length(processCellArray{1}{1}))
% Each condition is printed separately
ip = inputParser;
ip.KeepUnmatched = true;
ip.addParamValue('MIPSize',400,@isnumeric);
ip.addParamValue('splitMovie',false,@islogical);
ip.addParamValue('outFile',2,@isnumeric);
ip.addParamValue('forceSize',[200 400],@isnumeric);
ip.addParamValue('MIPMap',[],@isnumeric);
ip.addParamValue('invertLUT',0,@islogical);
ip.parse(varargin{:});
p=ip.Results;

if(~iscell(processCellArray{1}))
    processCellArray={processCellArray};
end
for cIdx=1:length(processCellArray)
    condition=processCellArray{cIdx};
    if(isempty(p.forceSize))
        rsize=[];
    else
        rsize=[200 400];
    end

    cellPlate=cell(length(condition{1}),length(condition));
	for pIdx=1:length(condition)
        for mIdx=1:length(condition{pIdx})
            img=imread(sprintfPath(condition{pIdx}(mIdx).outFilePaths_{p.outFile},1));
            if(~isempty(rsize))
                img=imresize(img,rsize);
            end
            cellPlate{mIdx,pIdx}=img;
        end
    end
    emptyMovie=cellfun(@(c) isempty(c),cellPlate);
    if(any(emptyMovie(:)))    
        cellPlate{emptyMovie}=uint8(zeros(rsize(1),3*rsize(2),3));
    end
    cellPlate=arrayfun(@(c) horzcat(cellPlate{c,:}),1:size(cellPlate,1),'unif',0);
    if(p.splitMovie)
        for mIdx=1:length(cellPlate)
            MD=condition{1}(mIdx).getOwner();
            if(isempty(MD.notes_))
                name=num2str(mIdx);
            else
                name=MD.notes_;
            end
            imwrite(cellPlate{mIdx},[outputDirPlot 'plate_' graphName '_' names{cIdx} '_Mov' name '.png']);
        end
    else
        render=vertcat(cellPlate{:});
        imwrite(render,[outputDirPlot 'plate_' graphName '_' names{cIdx} '.png']);
    end
end
