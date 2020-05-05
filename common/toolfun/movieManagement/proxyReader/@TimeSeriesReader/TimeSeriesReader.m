classdef TimeSeriesReader < CellReader
% TimeSeriesReader Reads XYT matrices as if arranged in a CxZ cell array
%

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    methods
        function obj = TimeSeriesReader(varargin)
            obj = obj@CellReader(varargin{:});
        end
        function s = getSize(obj)
            s = [obj.reader.getSizeC
                 obj.reader.getSizeZ]';
        end
        function subIndices = getLinSub(obj,varargin)
            % linearize c z
            subIndices = varargin;
            subIndices([1 3]) = obj.getLinSub@CellReader(varargin{ 1:2:nargin-1 });
        end
        function matrix = toMatrix(obj)
            % obj.to3D uses toCell, so the dimensions are rearranged
            matrix = reshape(obj.to3D,[obj.getSizeY obj.getSizeX obj.getSizeT obj.size]);
        end
        % need to fix subindexing
        function out = toCell(obj)
            S.type = '{}';
            S.subs = {':',':'};
            S = obj.expandSubs(S);
            out = obj.loadCell(S.subs{:});
        end


    end
    methods ( Access = protected )
        function images = loadCell(obj,varargin)
            varargin(nargin :3) = {NaN};
            [cv,zv tv] = deal(varargin{:});
            if(isnan(tv))
                tv = 1 : obj.getSizeT;
            end
            ndim = nargin - 1;

            subs = {cv tv zv};
            subsNan = cellfun(@(x) any(isnan(x)),subs);
            ctzImages = obj.loadCell@CellReader(subs{~subsNan});
            

            images = cell([length(cv) length(zv) 1]);
            for c = 1:length(cv)
                for z = 1:length(zv)
                        images{c,z} = cat(3, ctzImages{c,:,z} );
                end
            end
        end
        function R = getSubIndexReader(obj,S)
            if( length(S.subs) > 1 )
                % map Z back to the 3rd dimension if present
                S.subs{3} = S.subs{2};
            end
            % always include all time points when subindexing
            S.subs{2} = 1: obj.getSizeT;
            % linearize CZ if only one dimension is given
            S.subs = obj.getLinSub(S.subs{:});
            R = obj.getSubIndexReader@CellReader(S);
        end
        function Q = translateNamedIndex(obj,S)
            % swap t and z dimensions for named indexing
            map = struct('c','c','t','z','z','t');
            S(1).subs = map.(S(1).subs);
            Q = obj.translateNamedIndex@CellReader(S);
        end

    end
end
