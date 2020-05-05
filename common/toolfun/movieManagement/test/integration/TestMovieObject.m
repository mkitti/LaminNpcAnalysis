classdef TestMovieObject < TestLibrary
    
    properties
        path
        % ROI properties
        roiFolder = 'ROI';
        roiName = 'roiMovie.mat';
        roiMaskName = 'roiMask.tif';
    end
    
    methods
        %% Set up and tear down methods
        function setUp(self)
            uuid = char(java.util.UUID.randomUUID().toString());
            self.path = fullfile(self.tmpdir, uuid);
            if ~exist(self.path, 'dir'), mkdir(self.path); end
            [~, f] = fileattrib(self.path);
            self.path = f.Name;
        end
        
        function tearDown(self)
            rmdir(self.path, 's');
        end
        
        function rois = setUpROIs(self, nROIs, roiMask)
            
            if nargin < 3, roiMask = true(self.movie.imSize_); end
            % Create ROI folder
            rois(nROIs, 1) = MovieData();
            for i = 1 : nROIs
                roiPath = fullfile(self.movie.getPath(),...
                    [self.roiFolder '_' num2str(i)]);
                mkdir(roiPath);
                
                % Create ROI mask
                roiMaskFullPath = fullfile(roiPath, self.roiMaskName);
                imwrite(roiMask, roiMaskFullPath);
                
                % Create and save ROI
                rois(i) = self.movie.addROI(roiMaskFullPath, roiPath);
                rois(i).setPath(roiPath);
                rois(i).setFilename(self.roiName);
                rois(i).sanityCheck;
            end
        end
        
        %% Library methods
        function relocate(self)
            relocatedPath = [self.path '_relocated'];
            movefile(self.path, relocatedPath);
            self.path = relocatedPath;
        end

        function symlinkpath = createSymlink(self, realpath)
            uuid = char(java.util.UUID.randomUUID().toString());
            symlinkpath = fullfile(self.tmpdir, uuid);
            cmd = sprintf('ln -s %s %s', realpath, symlinkpath);
            system(cmd);
        end
    end
end
