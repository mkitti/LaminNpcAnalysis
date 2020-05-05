classdef LegacyReader < ProxyReader
% LegacyReader allows for getSize{X,Y,Z,C,T} and getBithDepth to be called with
% multiple parameters which are ignored but issues a warning.

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    methods
        function obj = LegacyReader(varargin)
            obj = obj@ProxyReader(varargin{:});
        end
        
        % Proxy all the functions
        % and ignore additional parameters
        function s = getSizeX(obj,varargin)
            s = obj.reader.getSizeX();
            if(nargin > 1)
                warning('LegacyReader:getSizeX',[class(obj.reader) '.getSizeX accepts no parameters.']);
            end
        end
        function s = getSizeY(obj,varargin)
            s = obj.reader.getSizeY();
            if(nargin > 1)
                warning('LegacyReader:getSizeY',[class(obj.reader) '.getSizeY accepts no parameters.']);
            end
        end
        function s = getSizeZ(obj,varargin)
            s = obj.reader.getSizeZ();
            if(nargin > 1)
                warning('LegacyReader:getSizeZ',[class(obj.reader) '.getSizeZ accepts no parameters.']);
            end
        end
        function s = getSizeC(obj,varargin)
            s = obj.reader.getSizeC();
            if(nargin > 1)
                warning('LegacyReader:getSizeC',[class(obj.reader) '.getSizeC accepts no parameters.']);
            end
        end
        function s = getSizeT(obj,varargin)
            s = obj.reader.getSizeT();
            if(nargin > 1)
                warning('LegacyReader:getSizeT',[class(obj.reader) '.getSizeT accepts no parameters.']);
            end
        end
        function s = getBitDepth(obj,varargin)
            s = obj.reader.getBitDepth();
            if(nargin > 1)
                warning('LegacyReader:getBitDepth',[class(obj.reader) '.getBitDepth accepts no parameters.']);
            end
        end
    end
end

