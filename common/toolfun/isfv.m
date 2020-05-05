function isit = isfv(in)
%ISFV checks if the input is a valid FV (faces,vertices) surface mesh
%
% isit = isfv(in)
%
%   This function returns true if and only if the input is a valid FV
%   (faces,vertices) surface mesh, as used by patch, isosurface, etc.
%
% Hunter Elliott
% 4/2011
%

if nargin > 0 && isstruct(in) && numel(fieldnames(in)) == 2 ...
        && isfield(in,'faces') && isfield(in,'vertices') ...
        && size(in.faces,2)==3 && size(in.faces,1)>=1 ...
        && size(in.vertices,2) == 3 && size(in.vertices,1) >= 3
    isit = true;
else
    isit = false;
end

    
