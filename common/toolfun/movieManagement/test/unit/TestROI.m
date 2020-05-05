classdef TestROI < TestCase & TestLibrary
    
    methods
        function self = TestROI(name)
            self = self@TestCase(name);
        end
        
        %% Set up and tear down methods
        function setUp(self)
            self.setUpMovieData();
        end
        
        function tearDown(self)
            tearDown@TestLibrary(self);
        end
        
        %% ROI methods tests
        function testAddROILocal(self)
            roi = self.movie.addROI('test','');
            assertEqual(self.movie.rois_, roi);
            assertEqual(roi.parent_, self.movie);
            assertEqual(roi.roiMaskPath_, 'test');
            assertTrue(isempty(roi.roiOmeroId_));
        end
        
        function testAddROIOmero(self)
            roi = self.movie.addROI(1,'');
            assertEqual(self.movie.rois_, roi);
            assertEqual(roi.parent_, self.movie);
            assertEqual(roi.roiOmeroId_, 1);
            assertTrue(isempty(roi.roiMaskPath_));
        end
        
        function testGetROI(self)
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(self.movie.getROI(i), rois(i));
            end
        end
        
        function testGetAncestor(self)
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(rois(i).getAncestor(), self.movie);
            end
        end
        
        function testGetDescendants(self)
            rois = self.setUpRois();
            assertEqual(self.movie.getDescendants(), rois);
        end
        
        function testDeleteROI(self)
            rois = self.setUpRois();
            self.movie.deleteROI(1, false);
            assertEqual(self.movie.rois_, rois(2 : end));
            assertFalse(rois(1).isvalid);
        end
        
        function testDeleteROIs(self)
            rois = self.setUpRois();
            self.movie.deleteROI(1 : self.nRois - 1, false);
            assertEqual(self.movie.rois_, rois(self.nRois));
            for i = 1 : self.nRois -1
                assertFalse(rois(i).isvalid);
            end
        end
        
        % Shared process/package tests
        function testChannels(self)
            self.setUpMovieData(3);
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(rois(i).channels_, self.movie.channels_);
            end
        end
        
        function testPixelSize(self)
            self.movie.pixelSize_ = 100;
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(rois(i).pixelSize_, self.movie.pixelSize_);
            end
        end
        
        function testTimeInterval(self)
            self.movie.timeInterval_ = 1;
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(rois(i).timeInterval_, self.movie.timeInterval_);
            end
        end
        
        function testCamBitdepth(self)
            self.movie.camBitdepth_ = 16;
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(rois(i).camBitdepth_, self.movie.camBitdepth_);
            end
        end
        
        function testNumAperture(self)
            self.movie.numAperture_ = 1.4;
            rois = self.setUpRois();
            for i = 1 : self.nRois
                assertEqual(rois(i).numAperture_, self.movie.numAperture_);
            end
        end
        
        function testProcess(self)
            process = self.setUpProcess();
            rois = self.setUpRois();
            assertEqual(self.movie.processes_, {process});
            assertEqual(process.getOwner(), self.movie);
            for i = 1: self.nRois
                assertEqual(rois(i).processes_, {process});
            end
        end
        
        function testUnsharedProcess(self)
            rois = self.setUpRois();
            process = self.setUpProcess();
            assertEqual(self.movie.processes_, {process});
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testDeleteSharedProcessByIndex(self)
            self.setUpProcess();
            rois = self.setUpRois();
            self.movie.deleteProcess(1);
            assertTrue(isempty(self.movie.processes_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testDeleteSharedProcessByObject(self)
            process = self.setUpProcess();
            rois = self.setUpRois();
            self.movie.deleteProcess(process);
            assertTrue(isempty(self.movie.processes_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testDeleteSharedProcessFromROIByIndex(self)
            self.setUpProcess();
            rois = self.setUpRois();
            rois(1).deleteProcess(1);
            assertTrue(isempty(self.movie.processes_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testDeleteSharedProcessFromROIByObject(self)
            process = self.setUpProcess();
            rois = self.setUpRois();
            rois(1).deleteProcess(process);
            assertTrue(isempty(self.movie.processes_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testUnlinkSharedProcessFromROIByIndex(self)
            process = self.setUpProcess();
            rois = self.setUpRois();
            status = rois(1).unlinkProcess(1);
            assertTrue(status);
            assertEqual(self.movie.processes_, {process});
            for i = 2: self.nRois
                assertEqual(rois(i).processes_, {process});
            end
            assertTrue(isempty(rois(1).processes_));
        end
        
        function testUnlinkSharedProcessFromROIByObject(self)
            process = self.setUpProcess();
            rois = self.setUpRois();
            status = rois(1).unlinkProcess(process);
            assertTrue(status);
            assertEqual(self.movie.processes_, {process});
            for i = 2: self.nRois
                assertEqual(rois(i).processes_, {process});
            end
            assertTrue(isempty(rois(1).processes_));
        end
        
        function testUnlinkUnsharedProcessFromROIByIndex(self)
            rois = self.setUpRois();
            process = self.setUpProcess();
            status = rois(1).unlinkProcess(1);
            assertFalse(status);
            assertEqual(self.movie.processes_, {process});
            for i = 2: self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testUnlinkUnSharedProcessFromROIByObject(self)
            rois = self.setUpRois();
            process = self.setUpProcess();
            status = rois(1).unlinkProcess(process);
            assertFalse(status);
            assertEqual(self.movie.processes_, {process});
            for i = 1 : self.nRois
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testReplaceSharedProcess(self)
            self.setUpProcess();
            rois = self.setUpRois();
            newprocess = MockProcess(self.movie);
            self.movie.replaceProcess(1, newprocess);
            assertEqual(self.movie.getProcess(1), newprocess);
            for i = 1: self.nRois
                assertEqual(rois(i).getProcess(1), newprocess);
            end
        end
        
        function testSharedPackage(self)
            package = self.setUpPackage();
            rois = self.setUpRois();
            assertEqual(self.movie.getPackage(1), package);
            for i = 1: self.nRois
                assertEqual(rois(i).packages_, {package});
            end
        end
        
        function testUnsharedPackage(self)
            rois = self.setUpRois();
            package = self.setUpPackage();
            assertEqual(self.movie.getPackage(1), package);
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        function testDeleteSharedPackageByIndex(self)
            self.setUpPackage();
            rois = self.setUpRois();
            self.movie.deletePackage(1);
            assertTrue(isempty(self.movie.packages_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        function testDeleteSharedPackageByObject(self)
            package = self.setUpPackage();
            rois = self.setUpRois();
            self.movie.deletePackage(package);
            assertTrue(isempty(self.movie.packages_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        function testDeleteSharedPackageFromROIByIndex(self)
            self.setUpPackage();
            rois = self.setUpRois();
            rois(1).deletePackage(1);
            assertTrue(isempty(self.movie.packages_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        function testDeleteSharedPackageFromROIByObject(self)
            package = self.setUpPackage();
            rois = self.setUpRois();
            rois(1).deletePackage(package);
            assertTrue(isempty(self.movie.packages_));
            for i = 1: self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        function testUnlinkSharedPackageFromROIByIndex(self)
            package = self.setUpPackage();
            rois = self.setUpRois();
            status = rois(1).unlinkPackage(1);
            assertTrue(status);
            assertEqual(self.movie.packages_, {package});
            for i = 2: self.nRois
                assertEqual(rois(i).packages_, {package});
            end
            assertTrue(isempty(rois(1).packages_));
        end
        
        function testUnlinkSharedPackageFromROIByObject(self)
            package = self.setUpPackage();
            rois = self.setUpRois();
            status = rois(1).unlinkPackage(package);
            assertTrue(status);
            assertEqual(self.movie.packages_, {package});
            for i = 2: self.nRois
                assertEqual(rois(i).packages_, {package});
            end
            assertTrue(isempty(rois(1).packages_));
        end
        
        function testUnlinkUnsharedPackageFromROIByIndex(self)
            rois = self.setUpRois();
            package = self.setUpPackage();
            status = rois(1).unlinkPackage(1);
            assertFalse(status);
            assertEqual(self.movie.packages_, {package});
            for i = 1 : self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        function testUnlinkUnsharedPackageFromROIByObject(self)
            rois = self.setUpRois();
            package = self.setUpPackage();
            status = rois(1).unlinkPackage(package);
            assertFalse(status);
            assertEqual(self.movie.packages_, {package});
            for i = 1 : self.nRois
                assertTrue(isempty(rois(i).packages_));
            end
        end
        
        %% cleanupROIPackages integration tests
        function testCleanupROIPackagesNoKeep(self)
            self.setUpPackage(true);
            rois = self.setUpRois();
            cleanupROIPackages(self.movie, 'MockPackage', 'verbose', false);
            for i = 1: numel(self.movie.rois_)
                assertTrue(isempty(rois(i).packages_));
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testCleanupROIPackagesKeep(self)
            
            [package, process] = self.setUpPackage(true);
            rois = self.setUpRois();
            cleanupROIPackages(self.movie, 'MockPackage', 1, 'verbose', false);
            
            % Tests
            for i = 1: numel(self.movie.rois_)
                roiPackage = rois(i).getPackage(1);
                assertTrue(isa(roiPackage, 'MockPackage'));
                assertFalse(isequal(package, roiPackage));
                assertEqual(roiPackage.getOwner(), rois(i));
                assertEqual(roiPackage.getProcess(1), process);
            end
        end
        
        function testCleanupROIPackagesFromChild(self)
            
            self.setUpPackage(true);
            rois = self.setUpRois();
            cleanupROIPackages(rois(1), 'MockPackage', 'verbose', false);
            for i = 1: numel(self.movie.rois_)
                assertTrue(isempty(rois(i).packages_));
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testCleanupROIPackagesNoROI(self)
            
            rois = self.setUpRois();
            package = self.setUpPackage(true);
            cleanupROIPackages(self.movie, 'MockPackage', 'verbose', false);
            assertEqual(self.movie.packages_, {package});
            for i = 1: numel(self.movie.rois_)
                assertTrue(isempty(rois(i).packages_));
                assertTrue(isempty(rois(i).processes_));
            end
        end
        
        function testCleanupROIPackagesMultipleCalls(self)
            
            [package, process] = self.setUpPackage(true);
            rois = self.setUpRois();
            cleanupROIPackages(self.movie, 'MockPackage', 1, 'verbose', false);
            for i = 1: numel(self.movie.rois_)
                assertEqual(numel(rois(i).packages_), 1);
            end
            cleanupROIPackages(self.movie, 'MockPackage', 1, 'verbose', false);
            for i = 1: numel(self.movie.rois_)
                assertEqual(numel(rois(i).packages_), 1);
                roiPackage = rois(i).getPackage(1);
                assertTrue(isa(roiPackage, 'MockPackage'));
                assertFalse(isequal(package, roiPackage));
                assertEqual(roiPackage.getOwner(), rois(i));
                assertEqual(roiPackage.getProcess(1), process);
            end
        end
    end
end
