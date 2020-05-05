classdef TestMovieDataProcess < TestCase & TestProcess
    
    methods
        function self = TestMovieDataProcess(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUpMovieData();
            setUp@TestProcess(self);
        end
        
        function tearDown(self)
            tearDown@TestProcess(self);
        end
    end
end
