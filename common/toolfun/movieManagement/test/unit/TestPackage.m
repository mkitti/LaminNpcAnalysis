classdef TestPackage < TestLibrary
    
    properties
        package
    end
    
    methods
        %% Set up and tear down methods
        function setUp(self)
            self.package = self.setUpPackage();
        end
        
        %% Tests
        function testGetPackage(self)
            assertEqual(self.movie.getPackage(1), self.package);
        end
        
        function testGetPackageIndexByObject(self)
            assertEqual(self.movie.getPackageIndex(self.package), 1);
        end
        
        function testGetPackageIndexByName(self)
            assertEqual(self.movie.getPackageIndex(class(self.package)), 1);
        end
        
        function testGetPackageIndexMultiple(self)
            package2 = self.setUpPackage();
            assertEqual(self.movie.getPackageIndex(package2, Inf), [1 2]);
        end
        
        function testGetOwner(self)
            assertEqual(self.package.getOwner(), self.movie);
        end
        
        %% deletePackage tests
        function testDeletePackageByIndex(self)
            % Delete package by index
            self.movie.deletePackage(1);
            assertTrue(isempty(self.movie.packages_));
        end
        
        function testDeletePackageByObject(self)
            % Test package deletion by object
            self.movie.deletePackage(self.package);
            assertTrue(isempty(self.movie.packages_));
        end
        
        function testDeleteSameClassPackageByIndex(self)
            % Duplicate package class and test deletion by index
            package2 = self.setUpPackage();
            self.movie.deletePackage(1);
            assertEqual(self.movie.packages_, {package2});
        end
        
        function testDeleteSameClassPackageByObject(self)
            % Duplicate package class and test deletion by object
            package2 = self.setUpPackage();
            self.movie.deletePackage(self.package);
            assertEqual(self.movie.packages_, {package2});
        end
        
        function testDeleteLoadedPackageByIndex(self)
            % Link process to package and test deletion by index
            
            process = self.setUpProcess();
            self.package.setProcess(1, process);
            self.movie.deletePackage(1);
            assertEqual(self.movie.processes_, {process});
        end
        
        function testDeleteLoadedPackageByObject(self)
            % Link process to package and test deletion by object
            
            process = self.setUpProcess();
            self.package.setProcess(1, process);
            self.movie.deletePackage(self.package);
            assertEqual(self.movie.processes_, {process});
        end
        
        function testDeleteInvalidPackage(self)
            % Delete process object
            delete(self.package);
            assertFalse(self.movie.getPackage(1).isvalid);
            
            % Delete process using deletePackage method
            self.movie.deletePackage(1);
            assertTrue(isempty(self.movie.packages_));
        end
        
        %% Process tests
        function testGetProcess(self)
            process = self.setUpProcess();
            self.package.setProcess(1, process);
            
            assertEqual(self.package.getProcess(1), process);
        end
        
        function testLinkedProcessLinked(self)
            process = self.setUpProcess();
            self.package.setProcess(1, process);
            assertTrue(self.package.hasProcess(process));
        end
        
        function testHasProcessUnlinked(self)
            process = self.setUpProcess();
            assertFalse(self.package.hasProcess(process));
        end
        
        function testGetProcessIndex(self)
            process = self.setUpProcess();
            self.package.setProcess(1, process);
            assertEqual(self.package.getProcessIndex(process), 1);
        end
        
        function testGetProcessIndexUnlinked(self)
            process = self.setUpProcess();
            assertTrue(isempty(self.package.getProcessIndex(process)));
        end
        
        function testCreateDefaultProcess(self)
            self.package.createDefaultProcess(1);
            assertEqual(self.package.getProcess(1), self.movie.getProcess(1));
            assertTrue(isa(self.package.getProcess(1),...
                self.package.getProcessClassNames{1}));
        end
    end
end
