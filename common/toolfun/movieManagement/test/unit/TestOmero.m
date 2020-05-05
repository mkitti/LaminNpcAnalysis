classdef TestOmero < TestLibrary
    properties
        omeroId
        omeroSession
    end
    
    methods
        %% Set up and tear down methods
        function setUp(self)
            self.omeroSession = MockOmeroSession;
            self.omeroId = 1;
            self.movie.setOmeroId(self.omeroId);
            self.movie.setOmeroSession(self.omeroSession);
        end
        
        function tearDown(self)
            delete(self.omeroSession);
            tearDown@TestLibrary(self)
        end
        
        % Basic tests
        function testIsOmero(self)
            assertTrue(self.movie.isOmero());
        end
        
        function testGetOmeroId(self)
            assertEqual(self.movie.getOmeroId(), self.omeroId);
        end
        
        function testSetOmeroId(self)
            f = @() self.movie.setOmeroId(-1);
            assertExceptionThrown(f, 'lccb:set:readonly');
        end
        
        %% Can upload function
        function testCanUpload(self)
            self.movie.setOmeroSave(true);
            assertTrue(self.movie.canUpload());
        end
        
        function testCanNotUpload(self)
            self.movie.setOmeroSave(false);
            assertFalse(self.movie.canUpload());
        end
    end
end
