classdef CroppableMovieData < MovieData
    %CroppableMovieData MovieData subclass that can be cropped
    
    properties
        cropDataFile_
    end
    
    methods
        function obj = CroppableMovieData(varargin)
            % cropDataFile_ can be set as a parameter
            obj@MovieData(varargin{:});
            if(isempty(obj.cropDataFile_))
                obj.cropDataFile_ = [obj.outputDirectory_ filesep 'cropReader.mat'];
            end
        end
        function r = initReader(obj)
            r = initReader@MovieData(obj);
            % if cropDataFile_ exists, then create a CropReader that
            % will crop the images from the previous reader
            if(exist(obj.cropDataFile_,'file'))
                S = load(obj.cropDataFile_);
                if(all(S.positions{end}(:,1) <= r.getSizeY) && all(S.positions{end}(:,2) <= r.getSizeX))
                    r = CropReader(r,S.positions{end});
                end
            end
        end
        function setReader(obj, r)
            obj.setReader@MovieData(r);
            % On setting a reader, modify the dimensions to match the
            % dimensions of the new reader in terms of XYZT
            if(~isempty(r))
                % could be empty if trying to reinitialize the Reader
                obj.imSize_ = [ r.getSizeY() r.getSizeX() ];
                obj.nFrames_ = r.getSizeT();
                obj.zSize_ = r.getSizeZ();
                for c = length(obj.channels_)+1:r.getSizeC()
                    obj.channels_(c) = obj.channels_(mod(c-1,length(obj.channels_))+1).copy;
                end
            end
        end
        function crop(obj, position)
            % position is [x y w h] relative to the current image
            % dimensions
            
            if(nargin < 2)
                % if no position given, run movieViewer and use imrect to
                % acquire it
                h = movieViewer(obj);
                hr = imrect;
                wait(hr);
                position = round(getPosition(hr));
            end
            
            % find all the crop readers in the ProxyReader chain so that we
            % can reference the current position to the original movie
            cropReaders = CropReader.findCropReaders(obj.getReader());
            for cri = 1:length(cropReaders)
                r = cropReaders{cri};
                % shift by previous crop offset if it exists
                position = position + [r.position(1,[1 2]) 0 0];
            end
            
            try
                if(exist(obj.cropDataFile_,'file'))
                    S = load(obj.cropDataFile_);
                else
                    S.positions = {};
                end

                S.positions{end+1} = position;
                save(obj.cropDataFile_,'-struct','S');
            catch err
                disp(['Could not save crop area to ' obj.cropDataFile_]);
                disp(getReport(err));
            end
            if(nargin < 2)
                delete(hr);
                close(h);
            end
            % reinitialize the reader
            obj.setReader(obj.initReader);
        end
    end
    methods (Static)
        function croppedMovieData =  multiCrop(varargin)
            % Creates a CroppableMovieData with multiple simultaneous crop
            % positions. The positions are replicated as additional
            % channels.
            
            %% INPUT setup
            % TODO: There is more constructor logic here than I, mkitti,
            % would like. Figure out how to deal with more of this using
            % the main constructor.
            ip = inputParser;
            ip.addRequired('channels_or_paths',@(x) isa(x,'Channel') || isa(x,'MovieData') || ischar(x) || iscellstr(x));
%             ip.addOptional('importMetaData',true,@islogical);
            ip.addOptional('outputDirectory',pwd,@ischar);
            ip.addParameter('cropPositions',[],@(x) size(x,2) == 4);
            ip.KeepUnmatched = true;
            ip.parse(varargin{:});
            R = ip.Results;
            
            %% INPUT parsing
            % Set importMetaData to true for now
            R.importMetaData = true;
            U = ip.Unmatched;
            U = [fieldnames(U) struct2cell(U)]';
            U = [{R.importMetaData,R.outputDirectory} U(:)'];
            series = 0;
            
            %% Get the base channels
            % Convert channels_or_paths to a Channel object array
            if(ischar(R.channels_or_paths))
                % Let MovieData constructor deal with the hardwork
                R.channels_or_paths = MovieData(R.channels_or_paths,U{:});
            end
            if(isa(R.channels_or_paths,'MovieData'))
                % If we have a MovieData, extract the channels
                MD = varargin{1};
                series = MD.getSeries();
                R.channels_or_paths = MD.channels_.copy;
            end
            
            %% Replicate channels to cover the number of positions
            nC = length(R.channels_or_paths);
            nP = size(R.cropPositions,1); 
            channels(nC,nP) = Channel;
            channels(:,1) = R.channels_or_paths(:);
            for p = 2:size(R.cropPositions,1)
                channels(:,p) = channels(:,1).copy;
            end
            % Column major, so initial sequence should be maintained
            channels = channels(:)';
            
            %% Construct the CroppableMovieData object
            croppedMovieData = CroppableMovieData(channels,U{:});
            % If BioFormats, set the series
            if(croppedMovieData.isBF)
                croppedMovieData.setSeries(series);
            end
            
            % If we have a MD template, copy it's public properties
            if(exist('MD','var'))
                class = ?MovieData;
                publicProperties = cellfun(@(x) strcmp(x,'public'),{class.PropertyList.SetAccess});
                publicProperties = {class.PropertyList(publicProperties).Name};
                for i=1:length(publicProperties)
                    croppedMovieData.(publicProperties{i}) = MD.(publicProperties{i});
                end
            end
            
            % Move cropDataFile_ if possible since we are overwriting it
            try
                if(exist(croppedMovieData.cropDataFile_,'file'))
                    movefile(croppedMovieData.cropDataFile_,[croppedMovieData.cropDataFile_ '.bak']);
                end
                croppedMovieData.crop(R.cropPositions);
            catch err
                warning('Could not backup crop positions');
                disp(getReport(err))
            end
            croppedMovieData.sanityCheck();
        end
        function croppedMovieData = subDivide(MD,divisions,varargin)
            % Divide the MovieData according to the integer number of divisions
            % for each dimension corresponding to MD.imSize_
            if(~isa(MD,'MovieData'))
                % If object is not a MovieData object, try to make it one
                MD = MovieData(MD);
            end
            imSize = MD.imSize_./divisions;
            cropPositions = zeros(prod(divisions),4);
            for i = 0:divisions(1)-1
                for j = 0:divisions(2)-1
                    % flip coordinates for the crop
                    % substract one from width and height due to inclusive
                    % cropping
                    cropPositions(i+j*divisions(1)+1,:) = [j*imSize(2)+1 i*imSize(1)+1 imSize([ 2 1])-1];
                end
            end
            croppedMovieData = CroppableMovieData.multiCrop(MD,MD.outputDirectory_,'cropPositions',cropPositions,varargin{:});
        end
    end
    
end

