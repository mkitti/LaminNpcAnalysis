classdef TestChannel < TestLibrary & TestCase
    
    properties
        emissionWavelength = 500;
        excitationWavelength = 600
        imageTypes = Channel.getImagingModes()
        exposureTime = 100
        fluorophores = Channel.getFluorophores()
    end
    
    methods
        function self = TestChannel(name)
            self = self@TestCase(name);
        end
        
        function setUp(self)
            self.setUpChannels(1);
        end
        
        function tearDown(self)
            tearDown@TestLibrary(self);
        end
        
        %% Class test
        function testClass(self)
            assertTrue(isa(self.channels(1),'Channel'));
        end
        
        %% Individual property tests
        function testSetValidEmissionWavelength(self)
            self.channels(1).emissionWavelength_ = self.emissionWavelength;
            assertEqual(self.channels(1).emissionWavelength_, self.emissionWavelength);
        end        
                
        function testSetInvalidName(self)
            f= @() set(self.channels(1), 'name_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
            f= @() self.channels(1).setName(0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
                           
        function testSetValidName(self)
            self.setUpChannels(2)
            self.channels(1).setName('channel 1');
            assertEqual(self.channels(1).getName(), 'channel 1');
            self.channels(2).name_ = 'channel 2';
            assertEqual(self.channels(2).getName(),'channel 2');
        end
        
        function testSetInvalidEmissionWavelength(self)
            f= @() set(self.channels(1), 'emissionWavelength_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidExcitationWavelength(self)
            self.channels(1).excitationWavelength_ = self.excitationWavelength;
            assertEqual(self.channels(1).excitationWavelength_, self.excitationWavelength);
        end
        
        function testSetInvalidExcitationWavelength(self)
            f= @() set(self.channels(1), 'excitationWavelength_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidExposureTime(self)
            self.channels(1).exposureTime_ = self.exposureTime;
            assertEqual(self.channels(1).exposureTime_, self.exposureTime);
        end
        
        function testSetInvalidExposureTime(self)
            f= @() set(self.channels(1), 'exposureTime_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        function testSetValidiImageType(self)
            self.setUpChannels(numel(self.imageTypes))
            for i = 1 : numel(self.imageTypes)
                self.channels(i).imageType_ = self.imageTypes{i};
                assertEqual(self.channels(i).imageType_, self.imageTypes{i});
            end
        end
        
        function testSetInvalidImageType(self)
            f= @() set(self.channels(1), 'imageType_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidFlurophores(self)
            self.setUpChannels(numel(self.fluorophores))
            for i = 1 : numel(self.fluorophores)
                self.channels(i).fluorophore_ = self.fluorophores{i};
                assertEqual(self.channels(i).fluorophore_, self.fluorophores{i});
            end
        end
        
        function testSetInvalidFlurophore(self)
            f= @() set(self.channels(1), 'fluorophore_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
    end
end
