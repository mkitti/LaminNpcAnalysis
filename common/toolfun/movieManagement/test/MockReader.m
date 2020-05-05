classdef MockReader < Reader
    properties
        images = {}
    end
    methods
        function obj = MockReader(varargin)
            if(nargin < 1)
                obj.images = obj.createDefaultData();
            else
                obj.images = varargin{1};
            end
        end
        function I = createDefaultData(obj)
            sizeY = 10;
            sizeX = 20;
            sizeC = 3;
            sizeT = 5;
            sizeZ = 7;
            % create channels
            I = cell(sizeC,sizeT,sizeZ);
            for c = 1 : sizeC
                for t = 1 : sizeT
                    for z = 1 : sizeZ
                        I{c,t,z} = zeros(sizeY,sizeX,'uint16');
                        I{c,t,z}(:) = [ c t z]*[100 10 1]';
                    end
                end
            end
        end
        function o = getSizeX(obj)
            o = size(obj.images{1},2);
        end
        function o = getSizeY(obj)
            o = size(obj.images{1},1);
        end
        function o = getSizeZ(obj)
            o = size(obj.images,3);
        end
        function o = getSizeC(obj)
            o = size(obj.images,1);
        end
        function o = getSizeT(obj)
            o = size(obj.images,2);
        end
        function o = getBitDepth(obj)
            o = str2num( strrep(class(obj.images{1}),'uint','') );
        end
        function o = getImageFileNames(obj,c,t,z,varargin)
            if(nargin < 2); c = 1; end;
            if(nargin < 3); t = 1; end;
            if(nargin < 4); z = 1; end;
            o = ['mockReader' num2str(obj.images{c,t,z}(1,1)) '.test'];
        end
        function o = getChannelNames(obj,c)
            if(nargin < 2); c = 1; end;
            o = ['ch' num2str(c) ];
        end
    end
    methods( Access = protected )
        function I = loadImage_(obj,c,t,z)
            I = obj.images{c,t,z};
        end
    end
end
