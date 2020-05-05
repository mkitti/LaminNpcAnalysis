classdef TestBFMovieData < TestMovieData & TestCase
    
    properties
        fakename = 'test.fake';
    end
    
    methods
        function self = TestBFMovieData(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            bfCheckJavaPath();
            self.setUp@TestMovieData();
            r = loci.formats.in.FakeReader();
            self.imSize = [r.DEFAULT_SIZE_Y r.DEFAULT_SIZE_X];
            self.nChan = r.DEFAULT_SIZE_C;
            self.nFrames = r.DEFAULT_SIZE_T;
        end
        
        function tearDown(self)
            self.tearDown@TestMovieData();
        end
        
        function filename = createFakeFile(self)
            filename = fullfile(self.path, self.fakename);
            fid = fopen(filename, 'w');
            fclose(fid);
        end
        
        function filename = createFakeFileCompanion(self, content)
            filename = fullfile(self.path, [self.fakename '.ini']);
            fid = fopen(filename, 'w');
            fwrite(fid, content);
            fclose(fid);
        end
        
        function setUpMovie(self,varargin)
            filename = self.createFakeFile();
            self.movie = MovieData(filename,varargin{:});
        end
        
        function checkChannelPaths(self)
            for i = 1 : self.nChan
                assertEqual(self.movie.getChannel(i).channelPath_,...
                    fullfile(self.path, self.fakename))
            end
        end
        
        %% Constructor
        
        function testConstructor(self)
            filename = self.createFakeFile();
            self.movie = MovieData(filename);
            self.checkChannelPaths();
        end

        function testConstructorMetadata(self)
            filename = self.createFakeFile();
            self.createFakeFileCompanion('physicalSizeX=1');
            self.movie = MovieData(filename);
            self.checkChannelPaths();
        end
        
        function testConstructorMultiSeries(self)
            self.fakename = 'test&series=2.fake';
            filename = self.createFakeFile();
            movies = MovieData(filename);
            assertEqual(numel(movies), 2);
            assertEqual(movies(1).getReader().id, filename);
            assertEqual(movies(2).getReader().id, filename);
            assertEqual(movies(1).getReader().formatReader,...
                movies(2).getReader().formatReader);
            assertEqual(movies(1).getReader().series, 0);
            assertEqual(movies(2).getReader().series, 1);
        end

        function testOutputDirectoryAsOptional(self)
            self.setUpMovie(self.path);
        end

        function testOutputDirectoryAsParameter(self)
            self.setUpMovie('outputDirectory',self.path);
        end

        function testImportMetadata(self)
            self.setUpMovie(true);
            self.setUpMovie(true,self.path);
            self.setUpMovie(false,'outputDirectory',self.path);
            self.setUpMovie('importMetadata',true,'outputDirectory',self.path);
        end
        
        %% Typecasting tests
        function checkPixelType(self, classname)
            if strcmp(classname, 'single'),
                pixelsType = 'float';
            else
                pixelsType = classname;
            end
            self.fakename = ['test&pixelType=' pixelsType '.fake'];
            self.setUpMovie();
            I = self.movie.getChannel(1).loadImage(1);
            assertTrue(isa(I, classname));
        end
        
        function testINT8(self)
            self.checkPixelType('int8');
        end
        
        function testUINT8(self)
            self.checkPixelType('uint8');
        end
        
        function testINT16(self)
            self.checkPixelType('int16');
        end
        
        function testUINT16(self)
            self.checkPixelType('uint16');
        end
        
        function testUINT32(self)
            self.checkPixelType('uint32');
        end
        
        function testSINGLE(self)
            self.checkPixelType('single');
        end
        
        function testDOUBLE(self)
            self.checkPixelType('double');
        end
        
        %% Dimensions tests
        function testSizeX(self)
            self.fakename = 'test&sizeX=100.fake';
            self.imSize(2) = 100;
            self.setUpMovie()
            self.checkDimensions();
        end
        
        function testSizeY(self)
            self.fakename = 'test&sizeY=100.fake';
            self.imSize(1) = 100;
            self.setUpMovie()
            self.checkDimensions();
        end
        
        function testSizeZ(self)
            self.fakename = 'test&sizeZ=256.fake';
            self.zSize = 256;
            self.setUpMovie()
            self.checkDimensions();
        end
        
        function testSizeC(self)
            self.fakename = 'test&sizeC=4.fake';
            self.nChan = 4;
            self.setUpMovie()
            self.checkDimensions();
        end
        
        function testSizeT(self)
            self.fakename = 'test&sizeT=256.fake';
            self.nFrames = 256;
            self.setUpMovie()
            self.checkDimensions();
        end
        
        
        function testGetDimensions(self)
            sizeX = 10;
            sizeY = 20;
            sizeZ = 5;
            sizeC = 3;
            sizeT = 200;
            self.fakename = sprintf(...
                'test&sizeX=%g&sizeY=%g&sizeZ=%g&sizeC=%g&sizeT=%g.fake',...
                sizeX, sizeY, sizeZ, sizeC, sizeT);
            self.setUpMovie()
            dim = [sizeX sizeY sizeZ sizeC sizeT];
            assertEqual(self.movie.getDimensions(), dim);
            assertEqual(self.movie.getDimensions('XYZCT'), dim);
            assertEqual(self.movie.getDimensions('XYZTC'), dim([1 2 3 5 4]));
            assertEqual(self.movie.getDimensions('XYTZC'), dim([1 2 5 3 4]));
            assertEqual(self.movie.getDimensions('XYTCZ'), dim([1 2 5 4 3]));
            assertEqual(self.movie.getDimensions('XYCZT'), dim([1 2 4 3 5]));
            assertEqual(self.movie.getDimensions('XYCTZ'), dim([1 2 4 5 3]));
            assertEqual(self.movie.getDimensions('XYZ'), dim([1 2 3]));
            assertEqual(self.movie.getDimensions('XYT'), dim([1 2 5]));
            assertEqual(self.movie.getDimensions('XYC'), dim([1 2 4]));
        end
        
        %% Metadata tests
        function testPixelsSizeX(self)
            self.fakename = 'test&physicalSizeX=.3.fake';
            self.setUpMovie();
            assertElementsAlmostEqual(self.movie.pixelSize_, 300.0);
        end
        
        function testPixelsSizeY(self)
            self.fakename = 'test&physicalSizeY=.3.fake';
            self.setUpMovie();
            assertElementsAlmostEqual(self.movie.pixelSize_, 300.0);
        end
        
        function testPixelsSizeXY(self)
            self.fakename = 'test&physicalSizeX=.3&physicalSizeY=.3.fake';
            self.setUpMovie();
            assertElementsAlmostEqual(self.movie.pixelSize_, 300.0);
        end
        
        function testPixelsSizeMismatchingXY(self)
            % Mismatching physical sizes should throw an exception
            self.fakename = 'test&physicalSizeX=1&physicalSizeY=.3.fake';
%             assertExceptionThrown(@() self.setUpMovie(), '');
            self.setUpMovie();
            % See also matlab.unittest.qualifications.Assertable.assertWarning
            [~, msgid] = lastwarn;
            assertEqual(msgid,'bfImport:PixelSizeDifferentXY');
        end
        
        function testPixelsSizeZ(self)
            self.fakename = 'test&physicalSizeZ=.3.fake';
            self.setUpMovie();
            assertElementsAlmostEqual(self.movie.pixelSizeZ_, 300.0);
        end
        
        function testPixelsSizeXYZ(self)
            self.fakename = 'test&physicalSizeX=.3&physicalSizeY=.3&physicalSizeZ=.3.fake';
            self.setUpMovie();
            assertElementsAlmostEqual(self.movie.pixelSize_, 300.0);
            assertElementsAlmostEqual(self.movie.pixelSizeZ_, 300.0);
        end
        
        %% ROI tests
        function testAddROIMultiSeries(self)
            nMovies = 3;
            self.fakename = ['test&series=' num2str(nMovies) '.fake'];
            self.setUpMovie();
            assertEqual(numel(self.movie), nMovies);
            for i = 1 : nMovies
                self.movie(i).addROI('','');
                roi = self.movie(i).getROI(1);
                assertEqual(roi.getChannel(1), self.movie(i).getChannel(1));
                assertEqual(roi.getSeries(), self.movie(i).getSeries());
            end
        end
        
        %% Process tests
        function testCheckChanNum(self)
            self.fakename = 'test&sizeC=3.fake';
            self.setUpMovie();
            process = self.setUpProcess();
            assertTrue(process.checkChanNum(1));
            assertTrue(process.checkChanNum(2));
            assertTrue(process.checkChanNum(3));
            assertFalse(process.checkChanNum(0));
            assertFalse(process.checkChanNum(4));
        end
        function testCheckFrameNum(self)
            self.fakename = 'test&sizeT=3.fake';
            self.setUpMovie();
            process = self.setUpProcess();
            assertTrue(process.checkFrameNum(1));
            assertTrue(process.checkFrameNum(2));
            assertTrue(process.checkFrameNum(3));
            assertFalse(process.checkFrameNum(0));
            assertFalse(process.checkFrameNum(4));
        end
        function testCheckDepthNum(self)
            self.fakename = 'test&sizeZ=3.fake';
            self.setUpMovie();
            process = self.setUpProcess();
            assertTrue(process.checkDepthNum(1));
            assertTrue(process.checkDepthNum(2));
            assertTrue(process.checkDepthNum(3));
            assertFalse(process.checkDepthNum(0));
            assertFalse(process.checkDepthNum(4));
        end
        
        %%
        function testMultiSeriesSwitch(self)
            self.fakename = 'test&series=2.fake';
            filename = self.createFakeFile();
            movies = MovieData(filename);
            r = movies(1).getReader().formatReader;
            assertEqual(movies(2).getReader().formatReader, r);
            assertEqual(r.getSeries(), 1);
            movies(1).getChannel(1).loadImage(1, 1);
            assertEqual(r.getSeries(), 0);
            movies(2).getChannel(1).loadImage(1, 1);
            assertEqual(r.getSeries(), 1);
        end
        
        function testMemoizer(self)
            self.fakename = 'test.fake';
            self.setUpMovie();
            
            % Check Bio-Formats reader has been cached
            r = self.movie.getReader().formatReader;
            assertTrue(r.isSavedToMemo());
            assertFalse(r.isLoadedFromMemo());
            
            % Reload movie and check the reader is read from cache
            self.movie = MovieData.load(self.movie.getFullPath());
            r = self.movie.getReader().formatReader;
            assertFalse(r.isSavedToMemo());
            assertTrue(r.isLoadedFromMemo());
        end
    end
end
