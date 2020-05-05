classdef TestLinearReader < TestProxyReader
    methods
        function self = TestLinearReader(name,reader)
            if(nargin < 2)
                reader = MockReader;
            end
            self = self@TestProxyReader(name,LinearReader(reader));
        end
        function checkFcnToZ(obj,fcnProxy,fcnReader)
               if(nargin < 3)
                   fcnReader = fcnProxy;
               end
               rSize = [ obj.proxy.reader.getSizeC , obj.proxy.reader.getSizeT, obj.proxy.reader.getSizeZ ];
               linFcn = @(p,c,t,z) fcnProxy(p,sub2ind(rSize,c,t,z));
               obj.checkFcnToZ@TestProxyReader(linFcn,fcnReader);
        end
    end
end
