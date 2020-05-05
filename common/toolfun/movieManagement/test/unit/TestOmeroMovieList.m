classdef TestOmeroMovieList < TestCase & TestOmero
    
    methods
        function self = TestOmeroMovieList(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUpMovieList();
            setUp@TestOmero(self);
        end
        
        function tearDown(self)
            tearDown@TestOmero(self);
        end
    end
end
