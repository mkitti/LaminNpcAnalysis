function [maxXY,maxZY,maxZX,three]=computeMIPs(vol,varargin)
ip = inputParser;
ip.addOptional('ZXRatio',1,@isnumeric);
ip.addOptional('minInt',min(vol(:)),@isnumeric);
ip.addOptional('maxInt',max(vol(:)),@isnumeric);
ip.addParameter('frameIdx',[],@isnumeric);
ip.addParameter('raw',false);
ip.addParameter('compThree',true);
ip.parse(varargin{:});
p=ip.Results;

ZXRatio=p.ZXRatio;
minInt=p.minInt;
maxInt=p.maxInt;

ScaledZ=ceil(size(vol,3)*ZXRatio);
% find the maximum intensity projections
maxXY = (max(vol, [], 3));
maxZY = imresize((squeeze(max(vol, [], 2))),[size(vol,1) ScaledZ]);
maxZX = imresize((squeeze(max(vol, [], 1))),[size(vol,2) ScaledZ]);

if(~p.raw)
	maxXY = uint8((2^8-1)*mat2gray(maxXY,double([minInt,maxInt])));
	maxZY = uint8((2^8-1)*mat2gray(maxZY,double([minInt,maxInt])));
	maxZX = uint8((2^8-1)*mat2gray(maxZX,double([minInt,maxInt])));
else
	maxXY=uint16(maxXY);
	maxZY=uint16(maxZY);
	maxZX=uint16(maxZX);
end
% F=figure();
% imshow((maxXY));
% F=figure();
% hist(double(maxXY(:)));
% waitfor(F);

three=[];
% generate a single image with all three projections
if(p.compThree)
	three=projMontage(maxXY,maxZX',maxZY',false);
end

% three = uint8((2^8-1)*mat2gray(three,double([minInt,maxInt])));
