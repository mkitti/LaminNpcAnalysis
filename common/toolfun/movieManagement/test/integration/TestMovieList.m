classdef TestMovieList < TestMovieObject & TestCase
    
    properties
        movieList
        nMovies = 1;
    end
    
    methods
        function self = TestMovieList(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUp@TestMovieObject();
        end
        
        function movie = setUpMovie(self)
            filename = fullfile(self.path, 'test.fake');
            fid = fopen(filename, 'w');
            fclose(fid);
            movie = MovieData.load(filename);
        end
        
        function setUpMovieList(self, movies)

            if nargin < 2
                movies = self.setUpMovie();
            end
            
            self.movieList = MovieList(movies, self.path);
            self.movieList.setPath(self.path);
            self.movieList.setFilename('movieList.mat');
            self.movieList.sanityCheck();
        end
        
        function tearDown(self)
            delete(self.movieList);
            self.tearDown@TestMovieObject();
        end
        
        %% SanityCheck test
        function checkMovieList(self)
            assertTrue(isa(self.movieList,'MovieList'));
            assertFalse(isempty(self.movieList.getMovies));
            
            for i = 1 : self.nMovies
                assertTrue(isa(self.movieList.getMovie(i), 'MovieData'));
            end
        end
        
        
        %% Tests
        
        function testSimple(self)
            self.setUpMovieList();
            self.checkMovieList();
        end
        
        function testRelocate(self)
            self.setUpMovieList();
            
            % Perform relocation
            movieListPath = self.movieList.getPath();
            movieListName = self.movieList.getFilename();
            oldPath = self.path;
            self.relocate();
            
            % Load the relocated movie
            newPath = relocatePath(movieListPath, oldPath, self.path);
            newFullPath = fullfile(newPath, movieListName);
            self.movieList = MovieList.load(newFullPath, false);
            self.checkMovieList();
            
            % Test movie paths
            assertEqual(self.movieList.outputDirectory_, newPath);
            assertEqual(self.movieList.getPath, newPath);
        end
        
        function testLoadAbsolutePath(self)
            % Test MovieList loading from relative path
            
            self.setUpMovieList();
            self.movieList = MovieList.load(self.movieList.getFullPath());
            self.checkMovieList;
        end
        
        function testLoadRelativePath(self)
            % Test MovieList loading from relative path
            here = pwd;
            self.setUpMovieList();
            absolutePath = self.movieList.getPath();
            cd(self.movieList.getPath());
            relativePath = fullfile('.', self.movieList.getFilename());
            self.movieList = MovieList.load(relativePath);
            self.checkMovieList();
            assertEqual(self.movieList.getPath(), absolutePath);
            cd(here);
        end
        
        function testLoadSymlink(self)
            % Test MovieList loading from a symlink
            
            if ispc, return; end
            self.setUpMovieList();
            absolutePath = self.movieList.getPath();
            symlinkPath = self.createSymlink(absolutePath);
            symlinkFullPath = fullfile(symlinkPath, self.movieList.getFilename());
            self.movieList = MovieList.load(symlinkFullPath);
            self.checkMovieList();
            assertEqual(self.movieList.getPath(), absolutePath);            
        end
        
        function testLoadRegenerateMemoFile(self)
            % Test MovieList loading generate non-existing memo files
            
            self.setUpMovieList();
            
            % May need to modify this depending on resolution of https://github.com/openmicroscopy/bioformats/issues/3034
            filesepidx = strfind(self.path,filesep);
            % Check the memo file exists
            memoFilePath = fullfile(bfGetMemoDirectory,self.path(filesepidx(1):end), '.test.fake.bfmemo');
            assertTrue(exist(memoFilePath, 'file') == 2);
            % Delete the memo file
            delete(memoFilePath);
            assertFalse(exist(memoFilePath, 'file') == 2);
            % Load the movie list and check the memo file has been
            % regenerated
            self.movieList = MovieList.load(self.movieList.getFullPath());
            assertTrue(exist(memoFilePath, 'file') == 2);
        end
        
        %% ROI scenarios
        function testROILists(self)
            % Test movie list composed of multiple ROIs
            self.movie = self.setUpMovie();
            rois = self.setUpROIs(3);
            self.setUpMovieList(rois);
            assertEqual(self.movieList.getMovie(1).getAncestor(),...
                self.movieList.getMovie(2).getAncestor());            
            assertEqual(self.movieList.getMovie(1).getAncestor(),...
                self.movieList.getMovie(3).getAncestor());
            
            self.movieList = MovieList.load(self.movieList.getFullPath(), false);
            assertEqual(self.movieList.getMovie(1).getAncestor(),...
                self.movieList.getMovie(2).getAncestor());
            assertEqual(self.movieList.getMovie(1).getAncestor(),...
                self.movieList.getMovie(3).getAncestor());
        end
        
        function testAttachMovies(self)
            % Test movie list composed of multiple ROIs
            self.movie = self.setUpMovie();
            self.setUpMovieList(self.movie);
            assertTrue(eq(self.movieList.getMovie(1), self.movie));
            
            self.movie = MovieData.load(self.movie.getFullPath());
            assertFalse(eq(self.movieList.getMovie(1), self.movie));
            self.movieList.attachMovies(self.movie);
            assertTrue(eq(self.movieList.getMovie(1), self.movie));
        end
    end
end
