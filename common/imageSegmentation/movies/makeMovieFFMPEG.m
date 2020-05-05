%makeMovieFFMPEG(stack, varargin) generates a movie from the input stack using FFMPEG and libx264.
% FFMPEG with libx264 must be installed, and this function only works on a Unix system.
%
% Inputs: 
%           stack : 3D stack of movie frames
%
% Options:
%
%       framerate : The frame rate of the output movie. Default: 15
%
% Parameters:
%      'Destpath' : Destination directory for the movie. Default: current directory (pwd)
%       'Quality' : Quality setting for ffmpeg. Default: 22
%  'DynamicRange' : Dynamic range for display. Default: [min(stack) max(stack)]

% Francois Aguet, 10/16/2013

function makeMovieFFMPEG(stack, varargin)

ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('stack');
ip.addOptional('framerate', 15, @isposint);
ip.addParamValue('DestPath', []); % for movie
ip.addParamValue('FileName', 'movie.mp4', @ischar);
ip.addParamValue('Quality', 22, @isposint);
ip.addParamValue('DynamicRange', []);
ip.addParamValue('Scale', 1, @isscalar);
ip.parse(stack, varargin{:});


if isunix && ~system('which ffmpeg >/dev/null 2>&1')
    fprintf('Generating movie ... ');
    frameDest = ['.frames_tmp_mmffmpeg' filesep];
    [~,~] = mkdir(frameDest);
    
    
    if ~iscell(stack) % single channel
        dRange = ip.Results.DynamicRange;
        if isempty(dRange)
            dRange = double([min(stack(:)) max(stack(:))]);
        end
        
        nf = size(stack, 3);
        fmt = ['%0' num2str(ceil(log10(nf))) 'd'];
        for fi = 1:nf
            frame = scaleContrast(stack(:,:,fi), dRange);
            if ip.Results.Scale ~= 1
                frame = imresize(frame, ip.Results.Scale, 'nearest');
            end
            imwrite(uint8(frame), [frameDest 'frame_' num2str(fi, fmt), '.png']);
        end
    else
        dRange = ip.Results.DynamicRange;
        if isempty(dRange)
            dRange = {double([min(stack{1}(:)) max(stack{1}(:))]),...
                double([min(stack{2}(:)) max(stack{2}(:))])};
        end
        
        nf = size(stack{1}, 3);
        fmt = ['%0' num2str(ceil(log10(nf))) 'd'];
        for fi = 1:nf
            frame1 = scaleContrast(stack{1}(:,:,fi), dRange{1});
            frame2 = scaleContrast(stack{2}(:,:,fi), dRange{2});
            frame = cat(3, frame1, frame2, zeros(size(frame1)));
            if ip.Results.Scale ~= 1
                frame = imresize(frame, ip.Results.Scale, 'nearest');
            end
            imwrite(uint8(frame), [frameDest 'frame_' num2str(fi, fmt), '.png']);
        end
    end
    
    [ny,nx,~] = size(frame);
    fr = num2str(ip.Results.framerate);
    
    cmd = ['ffmpeg -y -r ' fr ' -i ' frameDest 'frame_' fmt '.png' ' -vf "scale=' num2str(2*floor(nx/2)) ':' num2str(2*floor(ny/2))...
        '" -c:v libx264 -crf ' num2str(ip.Results.Quality) ' -pix_fmt yuv420p ' ip.Results.DestPath ip.Results.FileName];
    system(cmd);
    rmdir(frameDest, 's');
    fprintf(' done.\n');
else
    fprintf('A unix system with ffmpeg installed is required to generate movies using this function.\n');
end
