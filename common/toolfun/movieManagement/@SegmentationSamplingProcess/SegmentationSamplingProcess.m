classdef SegmentationSamplingProcess < ImageSamplingProcess
    %Process for sampling segmented image or process output intensities 
    %
    % Hunter Elliott
    % 7/2010
    %
    
    methods (Access = public)
        
        function obj = SegmentationSamplingProcess(owner,varargin)
            
            if nargin == 0
                super_args = {};
            else
                % Input check
                ip = inputParser;
                ip.addRequired('owner',@(x) isa(x,'MovieData'));
                ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
                ip.addOptional('funParams',[],@isstruct);
                ip.parse(owner,varargin{:});
                outputDir = ip.Results.outputDir;
                funParams = ip.Results.funParams;
                
                % Define arguments for superclass constructor
                super_args{1} = owner;
                super_args{2} = SegmentationSamplingProcess.getName;
                super_args{3} = @sampleMovieSegmentation;
                if isempty(funParams)
                    funParams=SegmentationSamplingProcess.getDefaultParams(owner,outputDir);
                end
                super_args{4} = funParams;
                
            end
            
            obj = obj@ImageSamplingProcess(super_args{:});
        end
        
    end
    methods (Static)
        function name =getName()
            name = 'Segmentation Sampling';
        end
        function name= GUI()
            name =@segmentationSamplingProcessGUI;
        end
        
        function funParams = getDefaultParams(owner,varargin)
            % Input check
            ip=inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieData'));
            ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
            ip.parse(owner, varargin{:})
            outputDir=ip.Results.outputDir;
            
            % Set default parameters
            funParams.ChannelIndex = 1:numel(owner.channels_);%Image channels to sample. Default is to sample all channels
            funParams.MaskChannelIndex = [];%Channel to use masks from for sampling. Default is first channel with valid masks
            funParams.SegProcessIndex = [];%MaskProcess to use masks from for sampling. Default is newest proc present.
            funParams.ProcessIndex = [];%Process(es) to sample output from. Default is to use raw images            
            funParams.OutputName = '';%Default is to use raw images
            funParams.OutputDirectory = [outputDir  filesep 'segmentation_sampling'];
            funParams.BatchMode = false;
        end
        function samplableInput = getSamplableInput()
            % List process output that can be sampled
            processNames = horzcat('Raw images','DoubleProcessingProcess',...
                repmat({'KineticAnalysisProcess'},1,3),'FlowAnalysisProcess','ImageCorrectionProcess');
            samplableOutput = {'','','netMap','polyMap','depolyMap','speedMap',''};
            samplableInput=cell2struct(vertcat(processNames,samplableOutput),...
                {'processName','samplableOutput'});  
        end
        
        
    end
end