function movieArray = cropMovieArray(movieArray,cropChan,viewChan,outputDir)

%
%
%   Goes through an array of movieDatas and asks the user to crop them
%   using cropMovie.m 
%
%   Input:
%
%       movieArray - cell array of movieData structures.
%
%       cropChan - Integer indices of the channels to crop.
%
%       viewChan - The channel to display for the user to perform the crop
%       on.
%
%       outputDir - The directory to save the cropped images to. If
%                   specified, all folder names will have ROI_#_ prepended to
%                   them (where # is the number of the ROI) and will be
%                   saved as sub-directories of this directory. If not
%                   specified, the user will be asked to specify a
%                   directory for each cropped movie.
%
% Hunter Elliott, 3/2009
%
%

if nargin < 4
    outputDir = [];
end

if nargin < 3
    viewChan = [];
end

if nargin < 2
    cropChan = [];
end



nMovies = length(movieArray);


figHan = fsFigure(.75);

for j = 1:nMovies
    
    moreROI = true;    
    figure(figHan);
    clf
    nROI = 1;
    while moreROI
    
        %Crop this movie
        
        if ~isempty(outputDir)
            %Get movie folder name
            iSlash = regexp(movieArray{j}.analysisDirectory,filesep);
            foldName = movieArray{j}.analysisDirectory(max(iSlash)+1:end);
            roiFoldName = [outputDir filesep  'ROI_' num2str(nROI) '_' foldName];
        else
            roiFoldName = [];
        end
        movieArray{j} = cropMovie(movieArray{j},[],cropChan,viewChan,roiFoldName);
    
        button = questdlg('Are you done with this movie?','cropMovieArray','Yes','No','Abort','Abort');
        
        switch button            
            case 'Abort'
                return
            case 'Yes'
                moreROI = false;
        end                                
    
        nROI = nROI+1;
        
    end
    
    
end
close(figHan)
