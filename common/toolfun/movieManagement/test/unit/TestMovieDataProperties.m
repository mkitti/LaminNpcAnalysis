classdef TestMovieDataProperties < TestCase & TestLibrary
    
    properties
        timeInterval =  1
        numAperture = 1.4
        magnification = 100
        camBitdepth = 14
        pixelSize = 67
        pixelSizeZ = 100
        acquisitionDate = [2014 8 7 12 0 0]
    end
    
    methods
        function self = TestMovieDataProperties(name)
            self = self@TestCase(name);
        end
        
        function setUp(self)
            self.setUpMovieData();
        end
        
        function tearDown(self)
            tearDown@TestLibrary(self);
        end
        
        %% Individual property tests
        function testSetValidTimeInterval(self)
            self.movie.timeInterval_ = self.timeInterval;
            assertEqual(self.movie.timeInterval_, self.timeInterval);
        end
        
        function testSetInvalidTimeInterval(self)
            f= @() set(self.movie, 'timeInterval_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidNumericalAperture(self)
            self.movie.numAperture_ = self.numAperture;
            assertEqual(self.movie.numAperture_, self.numAperture);
        end
        
        function testSetInvalidNumericalAperture(self)
            f= @() set(self.movie, 'numAperture_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidMagnification(self)
            self.movie.magnification_ = self.magnification;
            assertEqual(self.movie.magnification_, self.magnification);
        end
        
        function testSetInvalidMagnification(self)
            f= @() set(self.movie, 'magnification_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidCamBitdepth(self)
            self.movie.camBitdepth_ = self.camBitdepth;
            assertEqual(self.movie.camBitdepth_, self.camBitdepth);
        end
        
        function testSetInvalidCamBitdepth(self)
            f= @() set(self.movie, 'camBitdepth_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidPixelsSize(self)
            self.movie.pixelSize_ = self.pixelSize;
            assertEqual(self.movie.pixelSize_, self.pixelSize);
        end
        
        function testSetInvalidPixelsSize(self)
            f= @() set(self.movie, 'pixelSize_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidPixelsSizeZ(self)
            self.movie.pixelSizeZ_ = self.pixelSizeZ;
            assertEqual(self.movie.pixelSizeZ_, self.pixelSizeZ);
        end
        
        function testSetInvalidPixelsSizeZ(self)
            f= @() set(self.movie, 'pixelSizeZ_', 0);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetValidAcquisitionDate(self)
            self.movie.acquisitionDate_ = self.acquisitionDate;
            assertEqual(self.movie.acquisitionDate_, self.acquisitionDate);
        end
        
        function testSetInvalidAcquisitionDate(self)
            f= @() set(self.movie, 'acquisitionDate_', [2014 8 7]);
            assertExceptionThrown(f,'lccb:set:invalid');
        end
        
        function testSetInvalidROIMaskPath(self)
            f= @() self.movie.setROIMaskPath(1);
            assertExceptionThrown(f, 'lccb:set:invalid');
        end
        
     	function testSetInvalidROIOmeroId(self)
            f= @() self.movie.setROIOmeroId('/path/to/mask');
            assertExceptionThrown(f, 'lccb:set:invalid');
        end

        function testOutputDirectoryAsOptional(self)
            nchannels = 2;
            self.setUpChannels(nchannels);
            self.movie = MovieData(self.channels, self.tmpdir);
        end

        function testOutputDirectoryAsParameter(self)
            nchannels = 2;
            self.setUpChannels(nchannels);
            self.movie = MovieData(self.channels, 'outputDirectory', self.tmpdir);
        end
        
        %% Multi        
        function values = getValues(self)
            values = {self.timeInterval, self.numAperture, self.pixelSize,...
                self.magnification, self.camBitdepth, self.pixelSize,...
                self.acquisitionDate};
        end
        
        function testSetMultipleProperties(self)
            set(self.movie, self.getProperties(), self.getValues());
            for i = 1 : numel(self.getProperties())
                assertEqual(self.movie.(self.getProperties{i}),...
                    self.getValues{i});
            end
        end
        
        function testMultiSetProperties(self)
            set(self.movie, self.getProperties(), self.getValues());
            set(self.movie, self.getProperties(), self.getValues());
            for i = 1 : numel(self.getProperties())
                assertEqual(self.movie.(self.getProperties{i}),...
                    self.getValues{i});
            end
        end
    end
    methods (Static)
        function properties = getProperties()
            properties = {'timeInterval_', 'numAperture_', 'pixelSize_',...
                'magnification_', 'camBitdepth_', 'pixelSizeZ_',...
                'acquisitionDate_'};
        end
        
    end
end
