classdef TestMovieLoad < TestMovieObject & TestCase
    
    properties
        moviePath
    end
    
    methods
        function self = TestMovieLoad(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUp@TestMovieObject();
            self.moviePath = fullfile(self.path, 'movie.mat');
        end
                
        function tearDown(self)
            self.tearDown@TestMovieObject();
        end
        %% Invalid load files
        
        function testNonExistingMATfile(self)
            assertExceptionThrown(...
                @() MovieData.load(self.moviePath), 'lccb:movieObject:invalidFilePath');
            assertExceptionThrown(...
                @() MovieList.load(self.moviePath), 'lccb:movieObject:invalidFilePath');
        end         

        function testInvalidMATfile(self)
            fid = fopen(self.moviePath, 'w');
            fwrite(fid, ' ');
            fclose(fid);

            assertExceptionThrown(@() MovieData.load(self.moviePath),...
                'lccb:movieObject:load');
        end
        
        function testMovieListCannotLoadMovieData(self)
            MD = MovieData();
            MD.setPath(self.path);
            MD.setFilename('movie.mat');
            MD.save();
            assertExceptionThrown(@() MovieList.load(self.moviePath),...
                'lccb:movieObject:load');
        end

        function testMultipleMovieData(self)
            MD1 = MovieData();
            MD2 = MovieData();
            arrayfun(@(x) x.setPath(self.path), [MD1 MD2]);
            arrayfun(@(x) x.setFilename('movie.mat'), [MD1 MD2]);
            save(MD1.getFullPath, 'MD1' , 'MD2');
            assertExceptionThrown(@() MovieData.load(MD1.getFullPath()),...
                'lccb:movieObject:load');
        end
        
        function testMovieDataArray(self)
            MD(2,1) = MovieData();
            arrayfun(@(x) x.setPath(self.path), MD);
            arrayfun(@(x) x.setFilename('movie.mat'), MD);
            save(MD(1).getFullPath, 'MD');
            assertExceptionThrown(@() MovieData.load(MD(1).getFullPath()),...
                'lccb:movieObject:load');
        end
        
        function testMovieDataCannotLoadMovieList(self)
            ML = MovieList();
            ML.setPath(self.path);
            ML.setFilename('movie.mat');
            ML.save();
            assertExceptionThrown(@() MovieData.load(ML.getFullPath()),...
                'lccb:movieObject:load');
        end
        
        function testMultipleMovieList(self)
            ML1 = MovieList();
            ML2 = MovieList();
            arrayfun(@(x) x.setPath(self.path), [ML1 ML2]);
            arrayfun(@(x) x.setFilename('movie.mat'), [ML1 ML2]);
            save(ML1.getFullPath, 'ML1' , 'ML2');
            assertExceptionThrown(@() MovieList.load(ML1.getFullPath()),...
                'lccb:movieObject:load');
        end
        
        function testMovieListArray(self)
            ML(2,1) = MovieList();
            arrayfun(@(x) x.setPath(self.path), ML);
            arrayfun(@(x) x.setFilename('movie.mat'), ML);
            save(ML(1).getFullPath, 'ML');
            assertExceptionThrown(@() MovieList.load(ML(1).getFullPath()),...
                'lccb:movieObject:load');
        end    
    end
end
