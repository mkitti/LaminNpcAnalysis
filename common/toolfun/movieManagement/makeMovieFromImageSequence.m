function [rect] = makeMovieFromImageSequence( pathFolder, frameRate, doCrop, rect)
%function [] = makeMovieFromImageSequence( pathFolder, frameRate) makes m4v
%movie file out of a folder containing tiff file series.
%   input: pathFolder: the absolute path to a folder containing tiff
%   series
%          frameRate: frameRate (default: 30 fps)
%   output: the output movie will have the same name as the folder name and
%   will be stored in the same level with the input folder.
% Sangyoon Han, December 2016
    if nargin<4
        rect=[];
    end
    if nargin<3
        doCrop=false;
        rect=[];
    end
    if nargin<2
        frameRate=30;
        doCrop=false;
        rect=[];
    end
    
    [parentPath,nameFolder]=fileparts(pathFolder);
    v=VideoWriter([parentPath filesep nameFolder]);
    imageNames=dir([pathFolder filesep '*.tif']);
    imageNames={imageNames.name}';
    v.FrameRate = frameRate;
    open(v)

    for ii=1:numel(imageNames)
       curImg = imread([pathFolder filesep imageNames{ii}]);
       if ii==1 && doCrop && isempty(rect)
           figure
           [curImg,rect]=imcrop(curImg,[]);
       elseif doCrop && ~isempty(rect)
           curImg=imcrop(curImg,rect);
       else
           rect=[];
       end
       if ii>1 && (size(curImg,1)~=size(prev_frame,1) || size(curImg,2)~=size(prev_frame,2))
           [xGrid,yGrid]=meshgrid(linspace(1,size(curImg,2),size(prev_frame,2)),...
               linspace(1,size(curImg,1),size(prev_frame,1)));
           [Xnew,Ynew]=meshgrid(1:size(curImg,2),1:size(curImg,1));
           for jj=1:size(curImg,3)
              newCurImg(:,:,jj) = interp2(Xnew,Ynew,double(curImg(:,:,jj)),xGrid,yGrid);
           end
           curImg=uint8(newCurImg);
       end
       writeVideo(v,curImg)
       prev_frame=curImg;
    end
    close(v)
    disp(['Done! The movie ' v.Filename ' will be saved in ' parentPath '.'])
        
end

