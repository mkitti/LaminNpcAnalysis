function ML=indexLatticeData(moviePaths,moviesRoot,varargin)
% - Create movieData and analysis folder for each movie
% - Create a movieList saved in an analysis folder below <moviesRoot>
% - Print MIP in analysis folder (Optional)
% - If necessary, batch sort time points in ch0/, ch1/ for each movies
% - Optionnaly deskew, dezip on demand)
%
% EXAMPLE1:  indexLSFMData(  '/path/to/your/cells/Cell_*/whatever/CAM_0{ch}*.tif','/path/to/your/cells', 'timeInterval',1.03,'createMIP',true)
%M
% INPUT:  - moviePaths is either: 
%              ** A regular expression describing all the file of intereste using the following format: 
%                '/path/to/cell/Cell_*/path/to/tiff/xp_whatever_chanel_{ch}_*.tif'
%                - each images related to a cell must be in a separate folder
%                - the token {ch} represents the location of the channel number. It is mandatory.  
%                
%              ** a  matlab cell of path  that represent cell  directories containing *.tif files  ( or optionnaly compressed  *.tif.bz2) describing
%                 individual timepoint.
%                 - The option 'filePattern' must thus be used to describe channel name for example: 
%                   'Iter_ sample_scan_3p35ms_zp4um_ch{ch}_stack*'
%
%         - moviesRoot: original root for the list of movies:
%               ** contain the analysis folder with the movieList.mat and
%               associated outputdir
%               **  



ML=indexLSFMData(moviePaths,moviesRoot,'lateralPixelSize',100,'axialPixelSize',216,'chStartIdx',0,'createMIP',false,varargin{:});

