classdef TestTiffSeriesReader <  TestCase
    
    properties
        path
        reader
        sizeX = 10
        sizeY = 20
        sizeC = 1
        sizeT = 1
        sizeZ = 1
        imClass = 'uint8'
    end
    
    methods
        function self = TestTiffSeriesReader(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            java_tmpdir = char(java.lang.System.getProperty('java.io.tmpdir'));
            uuid = char(java.util.UUID.randomUUID().toString());
            self.path = fullfile(java_tmpdir, uuid);
            mkdir(self.path);
        end
        
        function tearDown(self)
            delete(self.reader);
            if exist(self.path, 'dir') == 7,
                rmdir(self.path, 's');
            end
        end
        
        function checkDimensions(self)
            assertEqual(self.reader.getSizeC, self.sizeC);
            for c = 1 : self.sizeC
                assertEqual(self.reader.getSizeX(), self.sizeX);
                assertEqual(self.reader.getSizeY(), self.sizeY);
                assertEqual(self.reader.getSizeZ(), self.sizeZ);
                assertEqual(self.reader.getSizeT(), self.sizeT);
            end
        end
        
        function checkLoadImage(self)
            I = zeros(self.sizeY, self.sizeX, self.sizeT, self.imClass);
            for c = 1 : self.sizeC
                for z = 1 : self.sizeZ
                    for t = 1 : self.sizeT
                        I(:,:,t) = self.getPlane(c, t, z);
                    end
                    assertEqual(self.reader.loadImage(c, t, z), I(:,:,t));
                    for t = 1 : self.sizeT
                        assertEqual(self.reader.loadImage(c, 1 : t, z),...
                            cat(3, I(:, :, 1:t)));
                    end
                end
            end
        end
        
        function checkLoadStack(self)
            I = zeros(self.sizeY, self.sizeX, self.sizeZ, self.imClass);
            for c = 1 : self.sizeC
                for t = 1 : self.sizeT
                    for z = 1 : self.sizeZ
                        I(:,:,z) = self.getPlane(c, t, z);
                    end
                    assertEqual(self.reader.loadStack(c, t), cat(3, I));
                    for z = 1 : self.sizeZ
                        assertEqual(self.reader.loadStack(c, t, 1:z),...
                            cat(3, I(:, :, 1:z)));
                    end
                end
            end
        end
        
        function I = getPlane(self, c, t, z)
            index = sub2ind([self.sizeC self.sizeT self.sizeZ], c, t, z);
            I = index * ones(self.sizeY, self.sizeX, self.imClass);
        end
        
        %% Test data formats
        function testIndividualTiffFiles(self)
            self.sizeT = 5;
            for t = 1 : self.sizeT
                imwrite(self.getPlane(1, t, 1),...
                    fullfile(self.path, ['test' num2str(t) '.tif']));
            end
            self.reader = TiffSeriesReader({self.path});
            
            self.checkDimensions();
            self.checkLoadImage();
            self.checkLoadStack();
            assertFalse(self.reader.isSingleMultiPageTiff(1));
        end
        
        function testSingleMultiPageTiff(self)
            self.sizeT = 5;
            imPath = fullfile(self.path, 'test.tif');
            imwrite(self.getPlane(1, 1, 1), imPath);
            for t = 2 : self.sizeT
                imwrite(self.getPlane(1, t, 1), imPath, 'write', 'append');
            end
            self.reader = TiffSeriesReader({self.path});
            
            self.checkDimensions();
            self.checkLoadImage();
            self.checkLoadStack();
            assertTrue(self.reader.isSingleMultiPageTiff(1));
        end
        
        function testMultipleMultiPageTiff(self)
            self.sizeT = 5;
            self.sizeZ = 3;
            for t = 1 : self.sizeT
                imPath = fullfile(self.path, ['test' num2str(t) '.tif']);
                imwrite(self.getPlane(1, t, 1), imPath);
                for z = 2 : self.sizeZ
                    imwrite(self.getPlane(1, t, z),...
                        imPath, 'write', 'append');
                end
            end
            self.reader = TiffSeriesReader({self.path});
            
            self.checkDimensions();
            self.checkLoadImage();
            self.checkLoadStack();
            
            assertFalse(self.reader.isSingleMultiPageTiff(1));
        end
        
        %% Test multiple channels
        function testMultiChannel(self)
            I = ones(self.sizeY, self.sizeX, 'uint8');
            self.sizeC = 4;
            chPath = cell(self.sizeC, 1);
            for c = 1 : self.sizeC
                chPath{c} = fullfile(self.path, ['ch' num2str(c)]);
                mkdir(chPath{c});
                imwrite(c * I, fullfile(chPath{c}, 'test.tif'));
            end
            self.reader = TiffSeriesReader(chPath);
            
            self.checkDimensions();
            for c = 1 : self.sizeC
                assertEqual(self.reader.loadImage(c, 1, 1), c * I);
            end
        end

        %% Test multiple channels with different dimensions
        function testMultiChannelRagged(self)
            self.sizeC = 3;
            self.sizeY = 50:10:70;
            self.sizeX = 60:10:80;
            self.sizeT = 5:7;
            self.sizeZ = 2:4;

            chPath = cell(self.sizeC, 1);
            I = ones(self.sizeY(end), self.sizeX(end), 'uint8');

            for c = 1 : self.sizeC
                S = I(1: self.sizeY(c), 1: self.sizeX(c));
                chPath{c} = fullfile(self.path, ['ch' num2str(c)]);
                mkdir(chPath{c});
                for t = 1: self.sizeT(c)
                    imwrite( (c+10*t) * S, fullfile(chPath{c}, ...
                        [ 'test' num2str(t) '.tif']));
                    for z = 2: self.sizeZ(c)
                        imwrite( (c+10*t) * S, fullfile(chPath{c}, ...
                            [ 'test' num2str(t) '.tif']),'WriteMode', 'append');
                    end
                end
            end
            self.reader = TiffSeriesReader(chPath);
            
            assertExceptionThrown(@() self.checkDimensions(), 'Reader:dimensionMismatch');
        end

        %% Test pixel types
        function testUINT8(self)
            I = ones(self.sizeY, self.sizeX, 'uint8');
            imwrite(I, fullfile(self.path, 'test.tif'));
            self.reader = TiffSeriesReader({self.path});
            
            assertEqual(self.reader.getBitDepth(), 8);
            assertEqual(self.reader.loadImage(1, 1, 1), I);
        end
        
        function testUINT16(self)
            I = ones(self.sizeY, self.sizeX, 'uint16');
            imwrite(I, fullfile(self.path, 'test.tif'));
            self.reader = TiffSeriesReader({self.path});
            
            assertEqual(self.reader.getBitDepth(), 16);
            assertEqual(self.reader.loadImage(1, 1, 1), I);
        end
    end
end
