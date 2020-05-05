function spy3d(matIn,varargin)
%SPY3D visualizes the sparseness of 3D matrices
%
% spy3d(matIn)
%
% spy3d(matIn,LineSpec)
%
% The spy function, but in 3d!!
% (This function visualizes the sparseness of an input 3d matrix.)
%
% Input:
%
% matIn - The matrix to visualize sparseness of. Must be 3D.
%
% LineSpec - A string or series of strings specifying the color/style to
% use to plot non-zero points. See LineSpec help for details. Optional. If
% not input, the '.' style is used and the color varies with height in the
% z plane (see Output below).
%
%
% Output:
%
%   No output, just a 3D figure with dots in each voxel which has a
%   non-zero value. The color of these dots is either as specified with the
%   argument LineSepc, or transitions from red to blue in the z-direction.
%
%
% Hunter Elliott
% Sometime in 2008?
%


if ndims(matIn) ~= 3
    error('Input matrix must be 3d!!')
end

if nargin < 2
    varargin = [];
end


P = size(matIn,3);

%Get axis hold state
ogHold = ishold(gca);
if ~ogHold
    %If hold wasn't on, clear before plotting.
    cla;
end
hold on

for p = 1:P
    
    %Find the non-zero values
    [row,col] = find(matIn(:,:,p));
    
    if isempty(varargin)
        %Plot them at the appropriate z-location
        plot3(col,row,p * ones(1,length(row)),'.','color',[ (P-p)/P 0 p/P ]);
    else
        plot3(col,row,p * ones(1,length(row)),varargin{:});
    end
    
end

%Set the viewpoint to 3d
view(3)
%Set axes scaling
axis equal
xlim([0 size(matIn,2)]);
ylim([0 size(matIn,1)]);
zlim([0 size(matIn,3)]);
%Return the original hold state if we've changed it.
if ~ogHold
    hold off
end