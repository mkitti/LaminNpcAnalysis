classdef TestChannelReader < TestProxyReader
    methods
        function obj = TestChannelReader(name)
            R = MockReader;
            obj = obj@TestProxyReader(name, ...
                    ChannelReader(R,R.getSizeC), ...
                    SubIndexReader(R,R.getSizeC,1:R.getSizeT,1:R.getSizeZ) ...
                    );
        end
        function checkFcn(self,fcnProxy,fcnReader)
            if(nargin < 3)
                fcnReader = fcnProxy;
            end
                assertEqual( fcnProxy(self.proxy) , ... 
                             fcnReader(self.reader) ) ;
        end

    end
end
