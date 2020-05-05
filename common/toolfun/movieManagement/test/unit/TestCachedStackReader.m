classdef TestCachedStackReader < TestProxyReader
    methods
        function obj = TestCachedStackReader(name)
            obj = obj@TestProxyReader(name,CachedStackReader(MockReader));
        end
    end
end
