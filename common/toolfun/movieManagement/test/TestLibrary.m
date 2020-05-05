classdef TestLibrary < handle
    %TESTLIBRARY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tmpdir = char(java.lang.System.getProperty('java.io.tmpdir'));
        channels = Channel.empty(1, 0)
        movie = MovieData.empty(1, 0)
        nRois
    end
    
    methods
        
        function tearDown(self)
            arrayfun(@delete, self.channels);
            if ~isempty(self.movie)
                cellfun(@delete, self.movie.processes_);
                cellfun(@delete, self.movie.packages_);
                delete(self.movie);
            end
        end
        
        function setUpMovieData(self, nchannels)
            if nargin > 1 && nchannels > 0
                self.setUpChannels(nchannels);
                self.movie = MovieData(self.channels, '');
            else
                self.movie = MovieData();
            end
        end
        
        function setUpChannels(self, nChannels)
            if nargin < 2, nChannels = 1; end
            for i = 1 : nChannels
                self.channels(i) = Channel(num2str(i));
            end
        end
        
        function setUpMovieList(self)
            self.movie = MovieList();
        end
        
        function rois = setUpRois(self, varargin)
            if nargin > 1
                self.nRois = varargin{1};
            else
                self.nRois  = 5;
            end
            rois(1, self.nRois) = MovieData();
            for i = 1 : self.nRois
                rois(i) = self.movie.addROI('','');
            end
        end
        
        function process = setUpProcess(self)
            process = MockProcess(self.movie);
            self.movie.addProcess(process);
        end
        
        function process2 = setUpProcessCompare(self)
            % To test different class types
            process2 = MockProcess2(self.movie);
            self.movie.addProcess(process2);
        end
        
        function [package, process] = setUpPackage(self, loaded)
            package = MockPackage(self.movie);
            self.movie.addPackage(package);
            
            if nargin > 1 && loaded
                process = setUpProcess(self);
                package.setProcess(1, process);
            else
                process = [];
            end
        end
    end
end

