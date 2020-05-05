function header = tif3dheader(rawMoviePath,rawMovieName,metaData)
%TIF3DHEADER reads 3D+t TIF files into the maki software package
%
%INPUT  rawMoviePath, rawMovieName: Movie path and name.
%       metaData: Selected metadata needed for image analysis. Structure with
%                 the following fields:
%           .pixelSizeXY       : Pixel size in x and y.
%           .thicknessZSlice   : Thickness of z-slice.
%           .wavelength        : Emission wavelength.
%           .exposureTime      : Exposure time.
%           .timeBetweenFrames : Time between consecutive frames (i.e.
%                                between full z-stacks).
%           .timeBetweenZSlices: Time between consecutive z-slices.
%           .objLensInfo       : Row vector with NA and magnification of
%                                objective lens.
%
%OUTPUT header: Same as output of readr3dheader.
%
%Khuloud Jaqaman, January 2010

%read in first stack of time lapse
imageInfo = imfinfo(fullfile(rawMoviePath,rawMovieName));

%extract header information

%voxel size
header.pixelX = metaData.pixelSizeXY;
header.pixelY = metaData.pixelSizeXY;
header.pixelZ = metaData.thicknessZSlice;

%keep empty for now
header.firstImageAddress = []; %not sure what this is or what it is used for

%objective lens information
header.lensID = metaData.objLensInfo;

%movie size in X, Y and Z
header.numCols = imageInfo(1).Width; %X in IMARIS
header.numRows = imageInfo(1).Height; %Y in IMARIS
header.numZSlices = length(imageInfo);

%number of time points
fileList = searchFiles('.tif$',[],rawMoviePath,1);
header.numTimepoints = size(fileList,1);

%emission wavelength information
header.numWvs = 1;
header.zwtOrder = 'ztw';
header.wvl = metaData.wavelength;

%exposure time and neutral density filter
header.expTime = metaData.exposureTime;
header.ndFilter = [];

%sampling time information
timeStamp = (0:header.numTimepoints-1)*metaData.timeBetweenFrames;
timeStamp = repmat(timeStamp,header.numZSlices,1) + ...
    repmat((0:header.numZSlices-1)'*metaData.timeBetweenZSlices,1,header.numTimepoints);
header.timestamp = timeStamp;
header.Time = timeStamp(:);
