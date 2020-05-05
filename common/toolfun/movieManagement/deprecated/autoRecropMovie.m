function movieData = autoRecropMovie(movieData,roiNumber)

%
% 
% movieData = autoRecropMovie(movieData,roiNumber)
% 
% This will use the ROI info saved in the movie's analysis directory to re-crop 
% the original images. This is useful when the original images have been re-processed
% in some way and you want the ROI to reflect these changes.
% 
% The input movieData can be a single movieData structure or a cell array of movieDatas
% 
% 
%
%Hunter Elliott, 4/2009

wasSingle = false;
if ~iscell(movieData)
    movieData = {movieData};
    wasSingle = true;
end


nMovies = length(movieData);

for iMov = 1:nMovies
    

    %movieData{iMov} = setupMovieData(movieData{iMov});


    try

        %First, make sure the movie has been cropped before
        if ~isfield(movieData{iMov},'ROI') || ~isfield(movieData{iMov}.ROI(1),'directory') || ~isfield(movieData{iMov}.ROI(1),'analysisDirectory')
            error(['The movie must be cropped before it can be automatically re-cropped! Movie # ' num2str(iMov)],mfilename);
        end


        if nargin < 2 || isempty(roiNumber)
            roiNumber = 1:length(movieData{iMov}.ROI);
        end

        
        
        for iRoi = roiNumber

            try

                disp(['Recropping movie ' num2str(iMov) ' of ' num2str(nMovies) ' ROI # ' num2str(iRoi) ' of ' num2str(length(roiNumber)) ]);

                cropChannels = []; %problem with overloaded variable name

                %Load the crop info variables
                cropVars = load([movieData{iMov}.ROI(1).directory filesep movieData{iMov}.ROI(iRoi).fileName],'cropChannels','cropPoly');


                
                %Re crop the movie using this same crop polygon and directory
                movieData{iMov} = cropMovie(movieData{iMov},cropVars.cropPoly,cropVars.cropChannels,[],movieData{iMov}.ROI(iRoi).analysisDirectory);
            catch errMess
                
                
        %TEMP - STORE ERROR IN MOVIEDATA, REMOVE IF OKAY ETC
        disp(['Error recropping movie ' num2str(iMov) ' ROI # ' num2str(iRoi) ' : ' errMess.message])                                    

                
            end
        end
        
    catch errMess

        %TEMP - STORE ERROR IN MOVIEDATA, REMOVE IF OKAY ETC
        disp(['Error recropping movie ' num2str(iMov) ': ' errMess.message])
        
    end
            


    
    
    
end



if wasSingle %Convert back to struct if necessary
    movieData = movieData{1};
end