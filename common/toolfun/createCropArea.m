function [area]=createCropArea(show_Image_path)
% Lets the user pre-define a ROI for cropping image stacks later on with
% the function: cropStack. This function is helpful, e.g. when you have to
% know where cells are (imaged e.g. in phase channel), but finally want to
% crop images from a different (fluorescence) channel in a cell-free area.
% In this case call createCropArea with the first phase image, define the
% ROI there and then crop the fluorescent images with cropStack using the
% output area from createCropArea.
%
% INPUT: 
% show_Image_path   Full path to the image in which you want to define the
%                   crop area, or a matrix representing the image.
%
% OUTPUT:
% area              ROI that is in the format understood by the function
%                   cropStack.
%--------------------------------------------------------------------------
% This function is based on code from cropStack. Achim Besser, 2010.

% Read first image
if ischar(show_Image_path)
    imgOne=double(imread(show_Image_path));
else
    imgOne=show_Image_path;
end
    

h=figure;
set(h,'NumberTitle','off');
set(h,'Name','Please draw region of interest');
% Normalize imgOne
imgOne=(imgOne-min(imgOne(:)))/(max(imgOne(:))-min(imgOne(:)));
% Crop - if the user closes the window without drawing, roipoly will return an error
try
    [~,area]=imcrop(imgOne);
catch
    uiwait(msgbox('No polygon selected. Quitting','Error','modal'));
    area=[];
    return
end
% Close figure
close(h);
% Check selected polygon
if area(3)==0 || area(4)==0
    uiwait(msgbox('Please chose an area, not a single pixel.','Error','error','modal'));
    area=[];
    return
end
% Round area (imcrop can give also non-integer boundaries)
area=round(area);
% Vertices
yTL=area(2); yBR=area(2)+area(4);
xTL=area(1); xBR=area(1)+area(3);

% Check boundaries
if yTL<=0, yTL=1; end
if xTL<=0, xTL=1; end
if yBR>=size(imgOne,1), yBR=size(imgOne,1); end
if xBR>=size(imgOne,2), xBR=size(imgOne,2); end

% Correct area
area=[yTL xTL yBR xBR];