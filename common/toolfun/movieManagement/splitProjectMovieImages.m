function splitProjectMovieImages(projectDir)
%SPLITMOVEIIMAGES splits multi-image .tif files into single tifs and places them in individual directories 
% 
% splitMovieImages(projectDir)
% 
% This function goes through every sub-directory of the directory
% projectDir and if that directory contains image files, a sub-directory
% called "Images" is created. Each image is then placed in a seperate
% sub-directory of this Image directory which is named after the image, and
% if it is a multi-page .tif or STK file, the pages are split into
% seperate, sequentially named files.
% 
% Input:
% 
%   projectDir - Parent directory containing sub-directories, each of
%   which contains images.
% 
% 
% Hunter Elliott
% 2/2010


storeName = 'originalStacks'; %The name of the directory to put the original stacks in after they have been split



allSub = dir(projectDir); %Check contents of project directory

allSub = allSub([allSub.isdir]' &  ...
    arrayfun(@(x)(~any(strcmp(x.name,{'.','..'}))),allSub)); %Remove all non-directories, and the . & .. directories. This works on PC & linux.

nSub = length(allSub);

for i = 1:nSub
    
    %Check for images in this directory
    im = imDir([projectDir filesep allSub(i).name]);
    
    if ~isempty(im)
        
        disp(['Splitting images for folder ' num2str(i)])
        
        %Set up the image directory
        imageDir = [projectDir filesep allSub(i).name filesep 'images'];        
        mkdir(imageDir)
        
        %Make a folder for storing the old stacks
        mkdir([projectDir filesep allSub(i).name filesep storeName]);
        
        %Write the images to seperate sub-dirs of this image dir
        for j = 1:length(im)
            
            %Make the image directory
            mkdir([imageDir filesep im(j).name(1:end-4)])%Name the directory after the stack, removing the file extension
            
            %Load all the images
            try
                currIm = stackRead([projectDir filesep allSub(i).name filesep im(j).name]);
            catch errMess
                disp(['stackRead.m failed: ' errMess.message ' Trying tif3Dread.m instead...'])
                %Tif3Dread is slower, but can open some files which the
                %current stackRead version fails to open
                currIm = tif3Dread([projectDir filesep allSub(i).name filesep im(j).name]);
            end
            nIm = size(currIm,3); %Check number of images
            %Get number of digits for writing file names
            nDig = floor(log10(nIm)+1);
            %Make the string for formatting
            fString = strcat('%0',num2str(nDig),'.f');
            %Write them all to new dir
            disp(['Splitting "' im(j).name '" into ' num2str(nIm) ' seperate files...'])
            for k = 1:nIm
                imwrite(squeeze(currIm(:,:,k)),[imageDir filesep im(j).name(1:end-4) filesep im(j).name(1:end-4) '_' num2str(k,fString) '.tif']);
            end
            
            movefile([projectDir filesep allSub(i).name filesep im(j).name],[projectDir filesep allSub(i).name filesep storeName])
            
        end
    else
        disp(['No images found in sub-folder ' allSub(i).name '!!']);
    end
    
    
    
    
end

