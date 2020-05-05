function namespace = getLCCBOmeroNamespace(varargin)
% getOmeroMovies creates or loads MovieData object from OMERO images
%
% SYNOPSIS
%
%
% INPUT
%    type -  a session
%
%    imageIDs - an array of imageIDs. May be a Matlab array or a Java
%    ArrayList.
%
%    path - Optional. The default path where to extract/create the
%    MovieData objects for analysis
%
% OUTPUT
%    namespace - an array of MovieData object corresponding to the images.
%
% Sebastien Besson, Nov 2012 (last modified Mar 2013)

types = {'', 'detection', 'tracking'};
ip = inputParser;
ip.addOptional('type', '', @(x) ismember(x, types));
ip.parse(varargin{:});

% Set temporary file to extract file annotations
namespace = 'lccb.analysis';
if ip.Results.type, namespace = [namespace '.' ip.Results.type]; end