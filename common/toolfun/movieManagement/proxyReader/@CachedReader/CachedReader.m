classdef CachedReader < ProxyReader
    %CachedReader Reader proxy class that caches loadImage and loadStack calls
    %
    % Use this class if you want to access previously read images from memory
    %
    % reader = CachedReader(  movieData.getReader() );
    
    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    properties
        cache = {};
    end
    
    methods
        function obj = CachedReader(varargin)
            obj = obj@ProxyReader(varargin{:});
            if(nargin > 0)
                obj.resetCache();
            end
        end

        function oldCache = resetCache(obj,varargin)
            % return the old cache in case anyone wants it
            oldCache = obj.cache;
            % use a cell array for the cache
            obj.cache = cell(obj.getSizeC,obj.getSizeT,obj.getSizeZ);
        end
    
        function [oldReader, oldCache] = setReader(obj,reader)
            oldReader = obj.setReader@ProxyReader(reader);
            oldCache = obj.resetCache();
        end
               
        function I = loadImage(obj, c, t, varargin)
            % check if unknown parameters
            if(nargin < 5)
                % use the generic validation which will redirect to loadImage_ below
                %I = obj.loadImage@Reader(varargin{:});
                %
                % but we have not merged that yet!
                ip = inputParser;
                ip.addRequired('c', @(x) insequence_and_scalar(x, 1 , obj.getSizeC));
                ip.addRequired('t', @(x) insequence_and_scalar(x, 1 , obj.getSizeT));
                ip.addOptional('z', 1, @(x) insequence_and_scalar(x, 1 , obj.getSizeZ));
                ip.parse(c, t, varargin{:});
                
                %c = ip.Results.c;
                %t = ip.Results.t;
                z = ip.Results.z;

                I = obj.loadImage_(c,t,z);
            else
                % unknown parameters so just proxy
                I = obj.reader.loadImage(varargin{:});
            end
        end
        function I = loadStack(obj,varargin)
            if(nargin < 5)
                % use the generic validation which will redirect to loadStack_ below
                I = obj.loadStack@Reader(varargin{:});
            else
                % more parameters than expected, passthru
                I = obj.reader.loadStack(varargin{:});
            end
        end
    end
    methods ( Access = protected )
        function I = loadImage_(obj,c,t,z)
            % check if cached
            if(isempty(obj.cache{c,t,z}))
                % no cache, so proxy and cache
                obj.cache{c,t,z} = obj.reader.loadImage_(c,t,z);
            end
            % return from cache
            I = obj.cache{c,t,z};
        end
        function I = loadStack_(obj,c,t,Z)
            % Z is a vector
            if(any(cellfun(@isempty,obj.cache(c,t,Z))))
                % if we are missing z-planes, proxy the call 
                % use generic loadStack which uses loadImage_ 
                I = obj.reader.loadStack_(c,t, Z );
                % save it into cache
                for zz = 1:length(Z)
                    obj.cache{c,t,Z(zz)} = I(:,:,zz );
                end
            else
                % we have cached the entire stack, so return it
                I = cat(3, obj.cache{c,t,Z});
            end
        end
    end
    
end

