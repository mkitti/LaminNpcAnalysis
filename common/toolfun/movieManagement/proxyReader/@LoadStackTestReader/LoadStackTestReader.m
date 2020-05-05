classdef LoadStackTestReader < ProxyReader
    % LoadStackTestReader compares the optimized loadStack to the generic loadStack
    % Used for testing execution times
    
    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    methods
        function obj = LoadStackTestReader(varargin)
            obj = obj@ProxyReader(varargin{:});
        end
        function I = loadStack(obj,varargin)
            I = obj.loadStack@Reader(varargin{:});
        end
        function [ratio,genericTime, specificTime] = compare(obj,varargin)
            tic;
            I = obj.loadStack(varargin{:});
            genericTime = toc;
            tic;
            J = obj.reader.loadStack(varargin{:});
            specificTime = toc;
            assert(all(I(:) == J(:)));
            ratio = genericTime/specificTime;
            disp(['Generic loadStack: ' num2str(genericTime)]);
            disp(['Specific loadStack: ' num2str(specificTime)]);
            disp(['Speed up: ' num2str(ratio)]);
        end
    end
end
