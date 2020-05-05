function [ zIndex,zIndexValue,zIndicies,zIndiciesValue, fm ] = autofocus( image_or_movie, roi, method)
%autofocus Autofocus driver function that wraps around fmeasure
% Focus is automatically determined by measuring the degree of focus using
% fmeasure and then finding the plane with the best measure(s).
%
% INPUT
% image_or_movie - (required) a 3D image stack YXZ or a MovieData object
% roi - (optional) rectangular roi, [xo yo xlength ylength], will prompt if empty
% method - (optional) char, see fmeasure, will prompt if empty
%
% OUTPUT
% zIndex - zIndex of best focused image plane
% zIndexValue - value of focus measure at best focal plane
% zIndices - vector of potential z-focal planes
% zIndiciesValue - vector of focus measure values at potential z-focal
%                  planes
%
% If a stack with more than one channel or additional dimensions is given
% then the autofocus will run on each channel separately. All of the outputs
% will be cell arrays with a length equal to the number of channels.
%
% See also fmeasure (extern/fex)

% Mark Kittisopikul, August 2018
% Goldman Lab
% Northwestern University

if(isnumeric(image_or_movie))
    S = image_or_movie;
elseif(isa(image_or_movie,'MovieData'))
    % If MovieData is given, use the stack of the first channel for ROI
    MD = image_or_movie;
    S = MD.channels_(1).loadStack(1);
end

if(nargin < 2 || isempty(roi))
    % If ROI is not provided, allow user to select a rectangle on the
    % maximum intensity projection
    hfig = figure;
    him = imshow(max(S,[],3),[]);
    disp('Please select a ROI');
    set(hfig,'Name','Please select a ROI');
    h = imrect(get(him,'Parent'));
    roi = wait(h);
    if(isempty(roi))
        error('autofocus:noroi','No ROI selected for autofocus.');
    end
    close(hfig);
end



if(nargin < 3 || isempty(method))
    % If no method is given, then allow user to select a method
    % Adapted from fmeasure
    methods = { ...
    'ACMO: Absolute central moment (Shirvaikar2004)', ...
    'BREN: Brenner''s focus measure (Santos97)', ...
    'CONT: Image contrast (Nanda2001)', ...
    'CURV: Image curvature (Helmli2001)', ...
    'DCTE: DCT Energy measure (Shen2006)', ...
    'DCTR: DCT Energy ratio (Lee2009)', ...
    'GDER: Gaussian derivative (Geusebroek2000)', ...
    'GLVA: Gray-level variance (Krotkov86)', ...
    'GLLV: Gray-level local variance (Pech2000)', ...
    'GLVN: Gray-level variance normalized (Santos97)', ...
    'GRAE: Energy of gradient (Subbarao92)', ...
    'GRAT: Thresholded gradient (Santos97)', ...
    'GRAS: Squared gradient (Eskicioglu95)', ...
    'HELM: Helmli''s measure (Helmli2001)', ...
    'HISE: Histogram entropy (Krotkov86)', ...
    'HISR: Histogram range (Firestone91)', ...
    'LAPE: Energy of Laplacian (Subbarao92)', ...
    'LAPM: Modified laplacian (Nayar89)', ...
    'LAPV: Variance of laplacian (Pech2000)', ...
    'LAPD: Diagonal Laplacian (Thelen2009)', ...
    'SFIL: Steerable filters-based (Minhas2009)', ...
    'SFRQ: Spatial frequency (Eskicioglu95)', ...
    'TENG: Tenegrad (Krotkov86)', ...
    'TENV: Tenengrad variance (Pech2000)', ...
    'VOLA: Vollat''s correlation-based (Santos97)', ...
    'WAVS: Wavelet sum (Yang2003)', ...
    'WAVV: Wavelet variance (Yang2003)', ...
    'WAVR: Wavelet ratio (Xie2006)'};
    method_idx = listdlg('ListString',methods,'ListSize',[300 400],'SelectionMode','single');
    if(isempty(method_idx))
        help fmeasure
        error('autofocus:nomethod','No method chosen for autofocus.');
    end
    method = methods{method_idx};
    method = method(1:4);
end

if(isa(image_or_movie,'MovieData'))
    % If this is a MovieData object, then run autofocus on each channel and
    % return a cell array with length equal to the number of channels
    % TODO: Avoid code duplication by making a multidimensional stack and
    % using the code below instead. This might be more memory efficient
    % though.
    nChannels = length(MD.channels_);
    zIndex = cell(1,nChannels);
    zIndexValue = cell(1,nChannels);
    zIndicies = cell(1,nChannels);
    zIndiciesValue = cell(1,nChannels);
    for c=1:nChannels
        [ zIndex{c},zIndexValue{c},zIndicies{c},zIndiciesValue{c} ] = autofocus(MD.channels_(c).loadStack(1),roi,method);
    end
    if(nargout == 0 && nChannels > 1)
        hfig = figure;
        imshowpair(MD.channels_(1).loadImage(1,zIndex{1}),MD.channels_(2).loadImage(1,zIndex{2}));
        set(hfig,'Name','Best Focused Image Plane');
    end
    return;
elseif(ndims(S) > 3)
    % If the given numeric matrix has more than 3 dimensions, assume the
    % z-dimension to be focused is the 3rd dimension. Each combination of
    % indices beyond the 3rd dimension will have it's own focus value.
    S = S(:,:,:,:);
    nChannels = size(S,4);
    zIndex = cell(1,nChannels);
    zIndexValue = cell(1,nChannels);
    zIndicies = cell(1,nChannels);
    zIndiciesValue = cell(1,nChannels);
    for c=1:nChannels
        [ zIndex{c},zIndexValue{c},zIndicies{c},zIndiciesValue{c} ] = autofocus(S(:,:,:,c),roi,method);
    end
    if(nargout == 0 && nChannels > 1)
        hfig = figure;
        imshowpair(S(:,:,zIndex{1},1),S(:,:,zIndex{2},2));
        set(hfig,'Name','Best Focused Image Plane');
    end
    return;
end

% Obtain focus metrics for each Z-plane
zSize = size(S,3);
fm = zeros(1,zSize);
for z=1:zSize
    fm(z) = fmeasure(S(:,:,z),method,roi);
end
% The selected z-plane is the plane with the highest focus measure
[zIndexValue,zIndex] = max(fm);
if(nargout > 2)
    % Since there might be multiple peaks, locate other local maxima
    [zIndiciesValue,zIndicies] = findpeaks(fm);
    % Make sure other local maxima peaks are higher than the average of the
    % median and the absolute maximum
%     s = zIndiciesValue > (zIndexValue+median(fm))/2;
%     zIndiciesValue = zIndiciesValue(s);
%     zIndicies = zIndicies(s);
end

if(nargout == 0)
    % Display best focused image plane
    hfig = figure;
    imshow(S(:,:,zIndex),[]);
    set(hfig,'Name','Best Focused Image Plane');
end

figure;
plot(fm);

end
