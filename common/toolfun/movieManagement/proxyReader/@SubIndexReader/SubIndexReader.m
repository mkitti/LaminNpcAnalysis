classdef SubIndexReader < ProxyReader
    %SubIndexReader Creates a reader with a subindex for subindexing into
    %another reader

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    properties
        subIndices = {};
        dimension = struct('C', 1' , 'T', 2, 'Z', 3);
    end
    
    methods
        function obj =  SubIndexReader(varargin)
            obj = obj@ProxyReader(varargin{ 1: min(1,nargin) });
            obj.setSubIndices(varargin{2:nargin});
        end
        function oldSubIndices = setSubIndices(obj,varargin)
            obj.subIndices = varargin;
            obj.subIndices(nargin:3) = {NaN};
        end
        function s = getSizeC(obj)
            s = length(obj.subIndices{obj.dimension.C});
        end
        function s = getSizeT(obj)
            s = length(obj.subIndices{obj.dimension.T});
        end
        function s = getSizeZ(obj)
            s = length(obj.subIndices{obj.dimension.Z});
        end
        function o = getChannelNames(obj,varargin)
            indices = obj.translate(varargin{:});
            o = obj.reader.getChannelNames(indices{:});
        end
        function o = getImageFileNames(obj,varargin)
            indices = obj.translate(varargin{:});
            o = obj.reader.getImageFileNames(indices{:});
        end
        function I = loadImage(obj,varargin)
            indices = obj.translate(varargin{:});
            I = obj.reader.loadImage(indices{:});
        end
        function I = loadStack(obj,varargin)
            indices = obj.translate(varargin{:});
            I = obj.reader.loadStack(indices{:});
        end
        function indices = translate(obj,varargin)
            indices = {};
            if(nargin < 2)
                return;
            end
            S = obj.subIndices;
            S = S(1:length(varargin));
            indices = cellfun(@(S,idx) S(idx),S,varargin,'UniformOutput',false);
            indices = indices(~cellfun(@isnan,indices));
        end
    end
    methods( Access = protected )
        function I = loadImage_(obj,varargin)
            indices = obj.translate(varargin{:});
            I = obj.reader.loadImage_(indices{:});
        end
        function I = loadStack_(obj,varargin)
            indices = obj.translate(varargin{:});
            I = obj.reader.loadStack_(indices{:});
        end
    end
    
    methods(Static)
        function r = getZStack(reader,c,t)
            r = SubIndexReader(reader,{c t 1:reader.getSizeZ});
        end
        function r = getCStack(reader,t,z)
            r = SubIndexReader(reader,{1:reader.getSizeC t z});
        end
        function r = getTStack(reader,c,z)
            r = SubIndexReader(reader,{c 1:reader.getSizeT z});
        end
        function r = getTimeSeries(reader,c,z)
            r = getTStack(reader,c,z);
        end
    end
    
end

