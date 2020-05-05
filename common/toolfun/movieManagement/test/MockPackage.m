classdef MockPackage < Package
    methods (Access = public)
        function obj = MockPackage(owner)
            obj = obj@Package(owner, MockPackage.getName);
        end
        
    end
    methods (Static)
        function GUI()
        end
        
        function name = getName()
            name = 'Mock package';
        end
        
        function m = getDependencyMatrix(i, j)
            m = [0 0; 1 0];
            if nargin<2, j=1:size(m,2); end
            if nargin<1, i=1:size(m,1); end
            m=m(i,j);
        end
        
        function processClassNames = getProcessClassNames()
            processClassNames = {'MockProcess'};
        end
        
        function procConst = getDefaultProcessConstructors()
            procConst = {@MockProcess};
        end
        
    end
end