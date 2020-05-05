classdef LinearReader < ProxyReader
    %LinearReader Allows for images to be loaded using linear indexing
    % 
    % Reader.loadImage typically accepts three indices in the order CTZ
    % Contrary to Matlab indexing behavior, linear indexing is not used
    % if less than three dimensions are given.
    %
    % LinearReader implements the Matlab linear indexing behavior
    % For example if the CTZ size were 4x1x47, the following indexing
    % will work:
    %
    %   % A normal reader gived an error since 188 > 4
    %   reader.loadImage(188);
    %   reader = LinearReader(reader);
    %   % For LinearReader, the following two lines are the same
    %   reader.loadImage(188);
    %   reader.loadImage(4,1,47);
    %
    % See also: ProxyReader
    %

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    methods
        function obj = LinearReader(varargin)
            obj = obj@ProxyReader(varargin{:});
        end
        % Obtain the CTZ size
        % Order is by convention from the reader interface
        function s = getSize(obj)
            s = [obj.reader.getSizeC
                 obj.reader.getSizeT
                 obj.reader.getSizeZ]';
        end
        % loadImage only loads one image at a time
        % Accept one to three parameters
        % Use the last index as a linear parameter
        function I = loadImage(obj,varargin)
            subIndices = obj.getLinSub(varargin{:});
            I = obj.reader.loadImage(subIndices{:});
        end
        % loadStack loads a Z-stack at a time
        function I = loadStack(obj,varargin)
            subIndices = obj.getLinSub(varargin{:});
            I = obj.reader.loadStack(subIndices{:});
        end
        % Determine the linearly indexed size given the number of
        % dimensions being indexed
        function linSize = getLinearSize(obj,ndim)
            ctzSize = obj.getSize();
       	    % if three parameters are given the size is [c t z]
       	    % if two parameter then size is [c t*z]
       	    % if one parameter then size is c*t*z
            linSize = [ctzSize(1:ndim-1) prod(ctzSize(ndim:end))];
        end
        % Get the linearized subindices if less than 3 dimensions given
        function sub = getLinSub(obj,varargin)
            ndim = nargin-1;
            maxdim = length(obj.getSize());
            if(ndim >= maxdim)
                % No conversion needed if all three dimensions given
                sub = varargin;
            else
                sub = cell(1,maxdim);
                linSize = obj.getLinearSize(ndim);
                % Convert to a single linear index
                % adding a trailing 1 ensures two dimensions are given
                ind = sub2ind([linSize 1],varargin{:});
                % Convert linear index to 3 subindices
                [sub{:}] = ind2sub(obj.getSize,ind);
            end
        end
    end
    methods ( Access = protected )
        function I = loadImage_(obj,varargin)
            subIndices = obj.getLinSub(varargin{:});
            I = obj.reader.loadImage_(subIndices{:});
        end
        % loadStack loads a Z-stack at a time
        function I = loadStack_(obj,varargin)
            subIndices = obj.getLinSub(varargin{:});
            I = obj.reader.loadStack_(subIndices{:});
        end
    end
    
end

