%KDTREECLOSESTPOINT for every query point in queryPts, find the closest point belonging to inPts
% 
% [idx, dist] = KDTreeClosestPoint(inPts,queryPts)
% 
% This function returns the index of the input point closest to each inPts.
% Supports 1D, 2D or 3D point sets.
%
% Input:
% 
%     inPts - an MxK matrix specifying the input points to test for distance
%     from the query points, where M is the number of points and K is the
%     dimensionality of the points.
% 
%     queryPts - an NxK matrix specifying the query points.
% 
% Output:
% 
%   idx - Nx1 array, the n-th element of which gives the index of
%   the input point closest to the the n-th query point.
% 
%   dist - Nx1 array, the n-th element of which gives the corresponding 
%   distance between the closest input point and the n-th query point.
%
