function header = stk3dheader(rawMoviePath,rawMovieName,metaData)
%STK3DHEADER reads 3D+t STK files into the maki software package
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
%Khuloud Jaqaman, August 2008

%read in first stack of time lapse
[stackData,numZSlices] = tiffread(fullfile(rawMoviePath,rawMovieName));

%extract header information

%voxel size
header.pixelX = metaData.pixelSizeXY;
header.pixelY = metaData.pixelSizeXY;
header.pixelZ = metaData.thicknessZSlice;

%keep empty for now
header.firstImageAddress = []; %not sure what this is or what it is used for

%objective lens information
header.lensID = [1.40 100];

%movie size in X, Y and Z
header.numCols = stackData(1).width; %X in IMARIS
header.numRows = stackData(1).height; %Y in IMARIS
header.numZSlices = numZSlices;

%number of time points
fileList = searchFiles('.STK$',[],rawMoviePath,1);
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
timeStamp = repmat(timeStamp,numZSlices,1) + ...
    repmat((0:numZSlices-1)'*metaData.timeBetweenZSlices,1,header.numTimepoints);
header.timestamp = timeStamp;
header.Time = timeStamp(:);
