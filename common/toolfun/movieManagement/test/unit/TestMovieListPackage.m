classdef TestMovieListPackage < TestCase & TestPackage
    
    methods
        function self = TestMovieListPackage(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUpMovieList();
            setUp@TestPackage(self);
        end
        
        function tearDown(self)
            tearDown@TestPackage(self);
        end
    end
end
