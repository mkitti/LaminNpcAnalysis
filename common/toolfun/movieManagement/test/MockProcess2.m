classdef MockProcess2 < Process
    methods (Access = public)
        function obj = MockProcess2(owner, varargin)
            obj = obj@Process(owner, MockProcess.getName);
            obj.funName_ = @(x) x;
            if nargin > 1
                obj.funParams_ = varargin{1};
            else
                obj.funParams_ = MockProcess2.getDefaultParams(owner);
            end
        end
        
    end
    methods (Static)
        function name = getName()
            name = 'Mock process Type 2';
        end
        
        function funParams = getDefaultParams(owner)
            % Input check
            ip=inputParser;
            ip.addRequired('owner', @(x) isa(x, 'MovieObject'));
            ip.parse(owner)
            
            % Set default parameters
            funParams.MockParam1 = true;
            funParams.MockParam2 = true;
        end
    end
end