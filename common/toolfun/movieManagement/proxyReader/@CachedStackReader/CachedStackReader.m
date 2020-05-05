classdef CachedStackReader < CachedReader
    %CachedStackReader Uses Reader.loadStack where possible to optimize
    %reading

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    properties
    end
    
    methods
        function obj = CachedStackReader(varargin)
            obj = obj@CachedReader(varargin{:});
        end
        % use loadImage and loadStack from CachedReader
        % which will use loadImage_ and loadStack_ below
    end
    methods ( Access = protected )
        function I = loadImage_(obj,c,t,z)
            % check if cached
            if(isempty(obj.cache{c,t,z}))
                % no cache, so proxy and cache
                % load whole stacks at a time
                I = obj.loadStack_(c,t,z);
            end
            % return from cache
            I = obj.cache{c,t,z};
        end
        function I = loadStack_(obj,c,t,Z)
            % load the whole stack
            I = obj.loadStack_@CachedReader(c,t,1:obj.getSizeZ);
            % only return what was requested
            I = I(:,:,Z);
        end
    end
end

