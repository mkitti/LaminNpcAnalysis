classdef TestCachedReader < TestProxyReader
    methods
        function obj = TestCachedReader(name)
            obj = obj@TestProxyReader(name,CachedReader(MockReader));
        end
    end
end
