classdef ImageOutputSelectionProcess < ImageProcessingProcess & NonSingularProcess
    %ImageOutputSelectionProcess Select an output from another process and
    %display it as an image
    %
    % This is useful when a process has a multiple image outputs. This
    % allows you to select a different output than default to display as an
    % image. This is really useful when another process like
    % ThresholdProcess selects only the default output. This can be used to
    % select a non-default output
    
    % Mark Kittisopikul, March 2017
    % Jaqaman Lab
    % UT Southwestern
    
    properties
    end
    
    methods
        function obj = ImageOutputSelectionProcess(owner,varargin)
%             if(nargin < 1)
%                 % Allow empty creation
%                 return;
%             end
            ip = inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieData'));
            ip.addOptional('funParams', ...
                ImageOutputSelectionProcess.getDefaultParams(owner), ...
                @(x) isstruct(x) || isnumeric(x));
            ip.parse(owner,varargin{:});
            
            if(isnumeric(ip.Results.funParams))
                funParams = ImageOutputSelectionProcess.getDefaultParams(owner,ip.Results.funParams);
            else
                funParams = ip.Results.funParams;
            end
            
            obj = obj@ImageProcessingProcess(owner, ... 
                'ImageOutputSelectionProcess', ... % name
                @(varargin) true, ... % funName
                funParams, ... % funParams
                owner.getChannelPaths, ... % inFilePaths_
                funParams.outFilePaths ... % outFilePaths_
                );
        end
        function varargout = loadChannelOutput(obj,iChan,varargin)
            ip = inputParser;
            ip.StructExpand = true;
            ip.KeepUnmatched = true;
            ip.addOptional('iFrame',1,@(x) all(obj.checkFrameNum(x)));
            ip.addParameter('output',[]); %ignore
            ip.parse(varargin{:});
            proc = obj.getParentProcess();
            [varargout{1:nargout}] = proc.loadChannelOutput(iChan,ip.Results.iFrame,'output',obj.funParams_.output,ip.Unmatched);
        end

        function status = checkChannelOutput(obj,varargin)
            proc = obj.getParentProcess();
            status = proc.checkChannelOutput(varargin{:});
        end
        
        function proc = getParentProcess(obj)
            proc = obj.owner_.processes_{obj.funParams_.processIndex};
        end

        function funParams = setParentProcess(obj,procOrProcID,output)
            % setParentProcess sets the process from which this process
            % will pull output from. It then sets the outFilePaths to match
            % the parent process
            %
            % INPUT
            % procOrProcID - Either a Process or an index of the process in
            %     owner.processes_ to select
            % output - (optional) Also select the output of interest
            %
            % OUTPUT
            % funParams - The new parameters that have been set
            if(isa(procOrProcID,'Process'))
                proc = procOrProcID;
                procID = find(cellfun(@(x) x == procOrProcID,obj.owner_.processes_),1,'first');
            else
                procID = procOrProcID;
                proc = obj.owner_.processes_(procID);
            end
            funParams = obj.getParameters();
            funParams.processIndex = procID;
            funParams.outFilePaths = proc.outFilePaths_;
            if(nargin > 2)
                funParams.output = output;
            end
            obj.setParameters(funParams);
        end
    end
    methods (Static)
        function funParams = getDefaultParams(owner,processIndex,varargin)
            isImageOutputSelectionProcess = ...
                cellfun(@(p) isa(p,'ImageOutputSelectionProcess'), ...
                owner.processes_);
            % Fields
            % processIndex - index of Process in owner to pull output from
            % output - output to select from Process indicates from
            %          processIndex
            % outFilePaths - Usually the outFilePaths of the Process of
            %                interest
            if(nargin < 2)
                funParams.processIndex = find(~isImageOutputSelectionProcess,1,'last');
            else
                funParams.processIndex = processIndex;
            end
            funParams.output = '';
            funParams.outFilePaths = {};
            if(~isempty(funParams.processIndex))
                funParams.outFilePaths = owner.processes_{funParams.processIndex}.outFilePaths_;
            end
        end
        function name = getName()
            name = 'ImageOutputSelectionProcess';
        end

    end
    
end

