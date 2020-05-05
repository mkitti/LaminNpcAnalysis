classdef TestMovieDataTiffSeries < TestMovieData & TestCase

    methods
        function self = TestMovieDataTiffSeries(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUp@TestMovieData();
        end
        
        function tearDown(self)
            self.tearDown@TestMovieData();
        end
        
        function channel = setUpChannel(self, channelPath, format)
            if nargin<3, format = 'double'; end
            for i = 1 : self.nFrames
                imwrite(zeros(self.imSize, format),...
                    fullfile(channelPath, ['test_' num2str(i) '.tif']));
            end
            channel = Channel(channelPath);
        end
        
        function setUpMovie(self, format)
            if nargin < 2,  format = 'uint8'; end
            channels(self.nChan, 1) = Channel();
            for i = 1 : self.nChan,
                channelPath = fullfile(self.path, ['channel_' num2str(i)]);
                mkdir(channelPath);
                channels(i) = self.setUpChannel(channelPath, format);
            end
            self.movie = MovieData(channels, self.path);
            self.movie.setPath(self.path);
            self.movie.setFilename('movieData.mat');
            self.movie.sanityCheck();
        end
        
        function checkChannelPaths(self)
            for i = 1 : self.nChan
                assertEqual(self.movie.getChannel(i).channelPath_,...
                    fullfile(self.path, ['channel_' num2str(i)]));
            end
        end
        
        %% Pixel Type tests
        function testUINT8(self)
            self.setUpMovie('uint8')
            I = self.movie.getChannel(1).loadImage(1);
            assertEqual(class(I), 'uint8');
        end
        
        function testUINT16(self)
            self.setUpMovie('uint16');
            self.movie = MovieData.load(self.movie.getFullPath());
            I = self.movie.getChannel(1).loadImage(1);
            assertEqual(class(I), 'uint16');
        end
        
        %% Dimensions test
        function testSizeX(self)
            self.imSize = [256 100];
            self.nChan = 1;
            self.nFrames = 1;
            self.setUpMovie();
            self.checkDimensions();
        end
        
        function testSizeY(self)
            self.imSize = [100 256];
            self.nChan = 1;
            self.nFrames = 1;
            self.setUpMovie();
            self.checkDimensions();
        end
        
        function testSizeC(self)
            self.imSize = [256 256];
            self.nChan = 4;
            self.nFrames = 1;
            self.setUpMovie();
            self.checkDimensions();
        end
        
        function testSizeT(self)
            self.imSize = [256 256];
            self.nChan = 4;
            self.nFrames = 256;
            self.setUpMovie();
            self.checkDimensions();
        end
        
        %% Invalid sizeT tests
        function testInvalidNumberFrames(self)
            self.setUpMovie();
            fullPath = self.movie.getFullPath();
            self.nFrames = self.nFrames + 1;

            self.setUpChannel(fullfile(self.path, 'channel_1'));
            assertExceptionThrown(@() MovieData.load(fullPath), 'MovieData:sanityCheck:nFrames');
        end
        
        function testInvalidImSize(self)
            self.setUpMovie();
            fullPath = self.movie.getFullPath();
            self.imSize = self.imSize / 2;
            self.setUpChannel(fullfile(self.path, 'channel_1'));
            assertExceptionThrown(@() MovieData.load(fullPath), 'MovieData:sanityCheck:imSize');
        end
        
    end
end
