classdef ChannelReader < SubIndexReader
    %ChannelReader Creates a reader confined to a single channel
    %

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    properties
        channel
    end
    
    methods
        function obj = ChannelReader(varargin)
            channel = [];
            if(nargin > 1)
                reader = varargin{1};
                c = varargin{2};
                assert(isscalar(c),'Channel number must be a scalar value');
                if(isa(reader,'Channel') && nargin == 1)
                   reader = reader.getReader();
                   % use c below
                   c = reader;
                end
                if(isa(c,'Channel'))
                    % save the channel as a property
                    channel = c;
                    % we could use subindex+1 instead
                    c = c.getChannelIndex();
                end
                if(nargin < 3 || varargin{3} == ':')
                    t = 1:reader.getSizeT;
                    varargin{3} = t;
                end
                if(nargin < 4 || varargin{4} == ':')
                    z = 1:reader.getSizeZ;
                    varargin{4} = z;
                end
            end
            obj = obj@SubIndexReader(varargin{:});
            if(~isempty(channel))
                obj.channel = channel;
            end
        end
    end
    
end

