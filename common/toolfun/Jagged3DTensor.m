classdef Jagged3DTensor
    %Jagged3DTensor 3D array structure where the 3rd dimension has a
    %varible length with the remaining values having a null value
    
    properties
        nullValue = NaN
        nullCountMap
        size_
        values
    end
    
    methods
        function obj = Jagged3DTensor(values,nullValue)
            if(nargin > 2)
                obj.nullValue = nullValue;
            end
            obj.size_ = size(values);
            obj.size_(length(obj.size_)+1:3) = 1;
            neFcn = obj.getNullEvaluator();
            nullMap = neFcn(values);
            numMapCS = cumsum(nullMap,3);
            obj.nullCountMap = numMapCS(:,:,end);
            [r,c] = ndgrid(1:obj.size_(1),1:obj.size_(2));
            s = obj.nullCountMap > 0;
            idx = sub2ind(obj.size_, r(s), c(s), obj.size_(3) - obj.nullCountMap(s)+1);
            assert(all(neFcn(values(idx))),'Values are not compacted with nulls only at end');
            obj.values = values(~nullMap);
            checkMem = whos('obj','values');
            if(diff([checkMem.bytes]) < 0)
                obj.nullCountMap = [];
                obj.values = values;
            end
        end
        function fcn = getNullEvaluator(obj)
            if(isnan(obj.nullValue))
                fcn = @isnan;
                return
            end
            nv = obj.nullValue;
            fcn = @(x) x == nv;
        end
        function fcn = getNullCreator(obj)
            if(isnan(obj.nullValue))
                fcn = @NaN;
                return;
            end
            if(obj.nullValue == 0)
                fcn = @zeros;
                return;
            end
            if(obj.nullValue == 1)
                fcn = @ones;
                return;
            end
            nv = obj.nullValue;
            fcn = @(varargin) genericNullCreator(nv,varargin{:});
        end
        function f = full(obj)
            if(isempty(obj.nullCountMap))
                f = obj.values;
                return;
            end
            nc = obj.getNullCreator();
            f = nc(obj.size_,'like',obj.values);
            nonNullMap = obj.size_(3)-obj.nullCountMap;
            v = obj.values;
            for z = 1:obj.size_(3)
                temp = f(:,:,z);
                s = z <= nonNullMap;
                ns = sum(s(:));
                temp(s) = v(1:ns);
                f(:,:,z) = temp;
                v = v(1+ns:end);
            end
        end
        function sz = size(obj)
            sz = obj.size_
        end
    end
    
end
function out = genericNullCreator(nullValue,sz,varargin)
    out = zeros(sz,varargin{:});
    out(:) = nullValue;
end
