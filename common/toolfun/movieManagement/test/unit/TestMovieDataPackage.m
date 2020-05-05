classdef TestMovieDataPackage < TestCase & TestPackage
    
    methods
        function self = TestMovieDataPackage(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUpMovieData();
            setUp@TestPackage(self);
        end
        
        function tearDown(self)
            tearDown@TestPackage(self);
        end
    end
end
