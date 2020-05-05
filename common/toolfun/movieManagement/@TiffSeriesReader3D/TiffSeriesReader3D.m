classdef  TiffSeriesReader3D < TiffSeriesReader
    % TiffSeriesReader reads tiff stacks containing a single channel each
    %
    % See also Reader, BioFormatsReader
    

    methods
        
        % Constructor
        function obj = TiffSeriesReader3D(channelPaths,varargin)
            obj=obj@TiffSeriesReader(channelPaths,varargin{:});
            obj.force3D = true;
            getDimensions(obj);
        end
        function B = sizeCheckNeed(obj)
            B=false;
        end
        function status = isSingleMultiPageTiff(obj, iChan)
            status = (obj.getSizeT()>1 || obj.getSizeZ()>1) && numel(obj.filenames{iChan})==1;
        end
        
    end
end
