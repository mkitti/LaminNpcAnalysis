classdef TestBioFormatsReader < TestCase
    
    properties
        id = 'test.fake';
        reader
        sizeZ=5
        sizeC=3
        sizeT=4
    end
    
    methods
        function self = TestBioFormatsReader(name)
            self = self@TestCase(name);
        end
        
        %% Test constructor
        function testDefaultConstructor(self)
            self.reader = BioFormatsReader(self.id);
            assertEqual(self.reader.id, self.id);
            assertEqual(self.reader.series, 0);
            assertTrue(isa(self.reader.formatReader,...
                'loci.formats.IFormatReader'));
            assertTrue(isa(self.reader.formatReader,...
                'loci.formats.Memoizer'));
        end
        
        function testConstructorMultiSeries(self)
            self.id = 'test&series=2.fake';
            self.reader = BioFormatsReader(self.id, 1);
            assertEqual(self.reader.id, self.id);
            assertEqual(self.reader.series, 1);
            assertTrue(isa(self.reader.formatReader,...
                'loci.formats.IFormatReader'));
        end
        
        function testConstructorReader(self)
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 'reader', r);
            assertEqual(self.reader.id, self.id);
            assertEqual(self.reader.series, 0);
            assertEqual(self.reader.formatReader, r);
        end
        
        function testConstructorMultiSeriesReader(self)
            self.id = 'test&series=2.fake';
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 0, 'reader', r);
            self.reader(2) = BioFormatsReader(self.id, 1, 'reader', r);
            assertEqual(self.reader(1).id, self.id);
            assertEqual(self.reader(2).id, self.id);
            assertEqual(self.reader(1).series, 0);
            assertEqual(self.reader(2).series, 1);
            assertEqual(self.reader(1).formatReader, r);
            assertEqual(self.reader(2).formatReader, r);
        end
        
        %% Test getReader
        function testGetReader(self)
            self.reader = BioFormatsReader(self.id);
            assertTrue(isa(self.reader.getReader(),...
                'loci.formats.IFormatReader'));
            assertEqual(char(self.reader.formatReader.getCurrentFile()), self.id);
        end
        
        function testGetReaderInit(self)
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 'reader', r);
            assertEqual(self.reader.getReader(), r);
            assertEqual(char(self.reader.formatReader.getCurrentFile()), self.id);
        end
        
        function testGetReaderMultiSeries(self)
            self.id = 'test&series=2.fake';
            self.reader = BioFormatsReader(self.id, 0);
            self.reader(2) = BioFormatsReader(self.id, 1);
            assertEqual(self.reader(1).formatReader.getSeries(), 0);
            assertEqual(self.reader(2).formatReader.getSeries(), 0);
            assertEqual(self.reader(1).getReader().getSeries(), 0);
            assertEqual(self.reader(2).getReader().getSeries(), 1);
        end
        
        function testGetReaderMultiSeriesReader(self)
            self.id = 'test&series=2.fake';
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 0, 'reader', r);
            self.reader(2) = BioFormatsReader(self.id, 1, 'reader', r);
            assertEqual(char(self.reader(1).formatReader.getCurrentFile()), self.id);
            assertEqual(char(self.reader(2).formatReader.getCurrentFile()), self.id);
            assertEqual(self.reader(1).formatReader.getSeries(), 0);
            assertEqual(self.reader(2).formatReader.getSeries(), 0);
            assertEqual(self.reader(1).getReader().getSeries(), 0);
            assertEqual(self.reader(2).getReader().getSeries(), 1);
        end
        
        function testGetReaderClose(self)
            self.reader = BioFormatsReader(self.id, 'reader', bfGetReader());
            assertTrue(isa(self.reader.getReader(),...
                'loci.formats.IFormatReader'));
            assertEqual(char(self.reader.formatReader.getCurrentFile()), self.id);
            self.reader.formatReader.close();
            assertTrue(isempty(self.reader.formatReader.getCurrentFile()));
            self.reader.getReader();
            assertEqual(char(self.reader.formatReader.getCurrentFile()), self.id);
        end
        
        function testGetReaderMultiSeriesClose(self)
            self.id = 'test&series=2.fake';
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 0, 'reader', r);
            self.reader(2) = BioFormatsReader(self.id, 1, 'reader', r);
            self.reader(2).formatReader.close();
            assertTrue(isempty(self.reader(1).formatReader.getCurrentFile()));
            assertTrue(isempty(self.reader(2).formatReader.getCurrentFile()));
            self.reader(1).getReader();
            assertEqual(char(self.reader(1).formatReader.getCurrentFile()), self.id);
            assertEqual(char(self.reader(2).formatReader.getCurrentFile()), self.id);
        end
        
        %% loadImage tests
        function testLoadImage(self)
            self.id = sprintf('test&sizeZ=%g&sizeC=%g&sizeT=%g.fake',...
                self.sizeZ, self.sizeC, self.sizeT);
            self.reader = BioFormatsReader(self.id);
            assertExceptionThrown(@() self.reader.loadImage(), 'MATLAB:minrhs')
            assertExceptionThrown(@() self.reader.loadImage(1), 'MATLAB:minrhs')
            assertExceptionThrown(@() self.reader.loadImage(0, 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadImage(self.sizeC + 1, 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadImage(1, 0),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadImage(1, self.sizeT + 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadImage(1, 1, 0),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadImage(1, 1, self.sizeZ + 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            
            I = zeros(512, 512, self.sizeT, 'uint8');
            for c = 1 : self.sizeC
                for z = 1 : self.sizeZ
                    for t = 1 : self.sizeT
                        I(:,:,t) = self.getPlane(1, c, t, z);
                        assertEqual(self.reader.loadImage(c, t, z), I(:,:,t));
                    end
                end
            end
        end
        
        function testLoadImageMultiSeries(self)
            self.id = 'test&series=2.fake';
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 0, 'reader', r);
            self.reader(2) = BioFormatsReader(self.id, 1, 'reader', r);
            assertEqual(self.reader(1).loadImage(1, 1, 1),...
                self.getPlane(1, 1, 1, 1));
            assertEqual(self.reader(2).loadImage(1, 1, 1),...
                self.getPlane(2, 1, 1, 1));
        end
        
        function testLoadStack(self)
            self.id = sprintf('test&sizeZ=%g&sizeC=%g&sizeT=%g.fake',...
                self.sizeZ, self.sizeC, self.sizeT);
            self.reader = BioFormatsReader(self.id);
            assertExceptionThrown(@() self.reader.loadStack(), 'MATLAB:minrhs')
            assertExceptionThrown(@() self.reader.loadStack(1), 'MATLAB:minrhs')
            assertExceptionThrown(@() self.reader.loadStack(0, 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadStack(self.sizeC + 1, 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadStack(1, 0),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadStack(1, self.sizeT + 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadStack(1, 1, 0),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            assertExceptionThrown(@() self.reader.loadStack(1, 1, self.sizeZ + 1),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            
            I = zeros(512, 512, self.sizeZ, 'uint8');
            for c = 1 : self.sizeC
                for t = 1 : self.sizeT
                    for z = 1 : self.sizeZ
                        I(:,:,z) = self.getPlane(1, c, t, z);
                    end
                    assertEqual(self.reader.loadStack(c, t), cat(3, I));
                    for z = 1 : self.sizeZ
                        assertEqual(self.reader.loadStack(c, t, 1:z),...
                            cat(3, I(:, :, 1:z)));
                    end
                end
            end
        end
        
        function testLoadStackMultiSeries(self)
            self.id = 'test&series=2.fake';
            r = bfGetReader(self.id);
            self.reader = BioFormatsReader(self.id, 0, 'reader', r);
            self.reader(2) = BioFormatsReader(self.id, 1, 'reader', r);
            assertEqual(self.reader(1).loadStack(1, 1, 1),...
                self.getPlane(1, 1, 1, 1));
            assertEqual(self.reader(2).loadStack(1, 1, 1),...
                self.getPlane(2, 1, 1, 1));
        end
        
        function I = getPlane(self, s, c, t, z)
            I = repmat(uint8(mod(0:512 - 1, 256)), 512, 1);
            I(1:10, 1:10) = s - 1;
            I(1:10, 11:20) = sub2ind([self.sizeZ self.sizeC self.sizeT], z, c, t) -1 ;
            I(1:10, 21:30) = z - 1;
            I(1:10, 31:40) = c - 1;
            I(1:10, 41:50) = t - 1;
        end
    end
end
