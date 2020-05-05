classdef TestChannelTiffSeries < TestTiffSeriesReader
%TestChannelTiffSeries Checks the interface between Channel and TiffSeriesReader
%
% Reuses TestTiffSeriesReader tests to check loadImage and loadStack Channel methods
%
% Here we override checkDimension, checkLoadImage, and checkLoadStack
% from TestTiffSeries reader which should get called during the tests.
%
% Generally, loadImage and loadStack should return identical output between
% Reader and Channel with c equal to the Channel's index
%
    properties
        channels
        movieData
        dimLength
        channelSanityCheckErr
        movieDataSanityCheckErr
    end
    methods
        function self = TestChannelTiffSeries(name)
            self = self@TestTiffSeriesReader(name);
        end

        function setUpChannels(self)
            % ensures that channels are setup based on the reader paths
            if(isempty(self.channels))
                self.channels = Channel(self.reader.paths{1});
                for c = 2 : self.sizeC
                    self.channels(c) = Channel(self.reader.paths{c});
                end
                checkDimLength(self);
                % movieData is needed to do a comprehensive test
                self.movieData = MovieData(self.channels,self.path);
                set(self.movieData,'movieDataPath_',self.path);
                set(self.movieData,'movieDataFileName_','test.mat');
            end
        end

        function checkDimLength(self)
            % This is an internal check to make sure that
            % TestTiffSeriesReader makes sense
        
            % check channel dependent lengths are all the same and equal to sizeC or 1
            dimLength = cellfun(@length,{self.sizeY self.sizeX self.sizeZ self.sizeT});
            assert( isscalar(unique(dimLength)) );
            dimLength = dimLength(1);
            % dimLength should be either 1 or self.sizeC
            assert( dimLength == 1 || dimLength == self.sizeC );
            self.dimLength = dimLength;
        end

        function checkSanityCheck(self)
            self.setUpChannels();
            % catch sanityCheck errors and store them as class properties
            % for test specific examination
            try
                    for c = 1 : self.sizeC
                        [w, h, n, z] = self.channels(c).sanityCheck(self.movieData);
                        % cc should either be 1 or c
                        cc = min(self.dimLength,c);
                        assertEqual( w, self.sizeX(cc) );
                        assertEqual( h, self.sizeY(cc) );
                        assertEqual( n, self.sizeT(cc) );
                        assertEqual( z, self.sizeZ(cc) );
                    end
            catch err
                self.channelSanityCheckErr = err;
            end
            try
                self.movieData.sanityCheck();
            catch err
                self.movieDataSanityCheckErr = err;
            end
        end


        function checkImageFileNames(self)
            self.setUpChannels();
            for c = 1 : self.sizeC
                fileNames = self.reader.getImageFileNames(c);
                assertEqual(self.channels(c).getImageFileNames(), ...
                            fileNames);
                for t = 1 : self.sizeT( min(c,self.dimLength) )
                    assertEqual(self.channels(c).getImageFileNames(t), ...
                                self.reader.getImageFileNames(c,t));
                end
            end
        end

        function checkDimensions(self)
            checkSanityCheck(self);
            checkImageFileNames(self);
        end

        % check that loadImage outputs are the same between Channel and Reader
        function checkLoadImage(self)
            self.setUpChannels();
            for c = 1 : self.sizeC
                for t = 1 : self.sizeT( min(c,self.dimLength) )
                    for z = 1 : self.sizeZ( min(c,self.dimLength) )
                        assertEqual(self.channels(c).loadImage(t,z), ...
                                    self.reader.loadImage(c,t,z));
                    end
                    assertEqual(self.channels(c).loadImage(t), ...
                                self.reader.loadImage(c,t));
                end
            end
        end

        % check that loadStack outputs are the same between Channel and Reader
        function checkLoadStack(self)
            self.setUpChannels();
            for c = 1 : self.sizeC
                for t = 1 : self.sizeT( min(c,self.dimLength) )
                    for z = 1 : self.sizeZ( min(c,self.dimLength) )
                        assertEqual(self.channels(c).loadStack(t,z), ...
                                    self.reader.loadStack(c,t,z));
                    end
                    assertEqual(self.channels(c).loadStack(t), ...
                                self.reader.loadStack(c,t));
                end
            end
        end

        function testMultiChannel(self)
            testMultiChannel@TestTiffSeriesReader(self);
            self.checkLoadImage();
            self.checkLoadStack();
        end

        function testMultiChannelRagged(self)

            % Because the Channels have different dimensions,
            % MovieData.sanityCheck should throw some assertion errors
            testMultiChannelRagged@TestTiffSeriesReader(self);

            % Failure should have occurred at the number of frames (time slice)            
            % Another error could occur first, order not important
            assertEqual(self.movieDataSanityCheckErr.identifier, ...
                'Reader:dimensionMismatch');

            % zSize_ should be empty since MovieData.sanityCheck did not complete
            assert(isempty(self.movieData.zSize_));
        end

    end
end
