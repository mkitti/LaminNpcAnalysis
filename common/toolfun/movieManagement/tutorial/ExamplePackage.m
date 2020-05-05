classdef ExamplePackage < Package
    
    methods
        function obj = ExamplePackage(owner,varargin)
            
            % Check input
            ip =inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieObject'));
            ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
            ip.parse(owner,varargin{:});
            outputDir = ip.Results.outputDir;

            super_args{1} = owner;
            super_args{2} = [outputDir  filesep 'ExamplePackage'];

            % Call the superclass constructor
            obj = obj@Package(super_args{:});
        end
    end
    
    methods (Static)
        
        function classes = getProcessClassNames(index)
            classes = {
                'ExampleProcess',...
                'ThresholdProcess',...
                'MaskRefinementProcess'};         
            if nargin == 0, index = 1 : numel(classes); end
            classes= classes(index);
        end
        
        function m = getDependencyMatrix(i,j)
            
            %    1 2 3
            m = [0 0 0;   %1 ExampleProcess
                 0 0 0;   %2 ThresholdProcess
                 0 1 0;]; %3 MaskRefinementProcess
            if nargin<2, j=1:size(m,2); end
            if nargin<1, i=1:size(m,1); end
            m=m(i,j);
        end
        
        function name = getName()
            name = 'Example';
        end
       
        function name = GUI()
           
        end
        function procConstr = getDefaultProcessConstructors(index)
            procConstr = {
                @ExampleProcess,...
                @ThresholdProcess,...
                @MaskRefinementProcess};
              
            if nargin == 0, index = 1 : numel(procConstr); end
            procConstr = procConstr(index);
        end
    end

    
end

