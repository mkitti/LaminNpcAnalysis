function [frame, xv, yv, sv, Av] = simGaussianSpots(nx, ny, sigma, varargin)
% SIMGAUSSIANSPOTS generates a given number of 2D Gaussians in an image.
% The generated Gaussian signals do not overlap with the image boundaries.
%
%   Input:
%           nx:    image size in x direction
%           ny:    image size in y direction
%           sigma: 2D Gaussian standard deviation (in pixels)
%
%   Options:
%           'x': x coordinates of centers of 2D Gaussians (can be subpixel)
%           'y': y coordinates of centers of 2D Gaussians (can be subpixel)
%           'A': amplitudes of 2D Gaussians
%           'npoints'   : number of 2D Gaussian to be generated
%           'Background': value of background
%           'Border' : border conditions: 'padded' (default), 'periodic', or 'truncated'
%           'Normalization: {'on' | 'off' (default)} divides Gaussians by 2*pi*sigma^2 when 'on'
%           'Verbose': {'on' | 'off' (default)}
%
%   Output:
%           frame: image with 2D Gaussian signals
%           xv:    x coordinates of centers of Gaussians (can be subpixel)
%           vy:    y coordinates of centers of Gaussians (can be subpixel)
%           sv:    vector of standard deviations
%           Av:    vector of amplitudes
%
% Example:
% img = simGaussianSpots(200, 100, 2, 'npoints', 50, 'Border', 'periodic');

% Francois Aguet, last modified July 30, 2012

ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('nx',@isnumeric);
ip.addRequired('ny',@isnumeric);
ip.addRequired('sigma',@isnumeric);
ip.addParamValue('x', []);
ip.addParamValue('y', []);
ip.addParamValue('A', []);
ip.addParamValue('npoints', 1);
ip.addParamValue('Background', 0);
ip.addParamValue('Window', []);
ip.addParamValue('Verbose', 'off', @(x) any(strcmpi(x, {'on', 'off'})));
ip.addParamValue('Border', 'padded', @(x) any(strcmpi(x, {'padded', 'periodic', 'truncated'})));
ip.addParamValue('Normalization', 'off', @(x) any(strcmpi(x, {'analytical', 'sum', 'off'})));
ip.addParamValue('NonOverlapping', false, @islogical);
ip.parse(nx, ny, sigma, varargin{:});

np = ip.Results.npoints;
c = ip.Results.Background;
xv = ip.Results.x(:);
yv = ip.Results.y(:);
Av = ip.Results.A(:);
sv = ip.Results.sigma(:);

if numel(xv) ~= numel(yv)
    error('''x'' and ''y'' must have the same size.');
end

if ~isempty(xv)
    np = length(xv);
end

% feature vectors
if numel(sv)==1
    sv = sv*ones(np,1);
end
wv = ip.Results.Window;
if isempty(wv)
    wv = ceil(4*sv);
elseif numel(wv)==1
    wv = wv*ones(size(sv));
end

w_max = 2*max(wv)+1;
if (w_max>nx || w_max>ny)
    error(['For a sigma of ' num2str(max(sv), '%.1f') ', nx and ny must be greater than ' num2str(2*w_max+1)]);
end

if numel(Av)==1
    Av = Av*ones(np,1);
end
if isempty(Av)
    Av = ones(np,1);
end

% Generate point coordinates, if input is empty
if strcmpi(ip.Results.Border, 'padded');
    % discard signals close to image border
    if ~isempty(xv)
        idx = xv <= wv | yv <= wv | xv > nx-wv | yv > ny-wv;
        xv(idx) = [];
        yv(idx) = [];
        Av(idx) = [];
        sv(idx) = [];
        if strcmpi(ip.Results.Verbose, 'on')
            fprintf('Number of discarded points: %d\n', numel(idx));
        end
        np = length(xv);
    else
        if ip.Results.NonOverlapping
            xv = [];
            yv = [];
            while numel(xv)<np
                xcand = (nx-2*wv-1).*rand(np,1) + wv+1;
                ycand = (ny-2*wv-1).*rand(np,1) + wv+1;
                idx = KDTreeBallQuery([xcand ycand; xv yv], [xcand ycand], 2*wv);
                idx(cellfun(@numel, idx)>1) = [];
                idx = vertcat(idx{:});
                xv = [xv; xcand(idx)]; %#ok<AGROW>
                yv = [yv; ycand(idx)]; %#ok<AGROW>
            end
            xv = xv(1:np);
            yv = yv(1:np);
        else
            xv = (nx-2*wv-1).*rand(np,1) + wv+1;
            yv = (ny-2*wv-1).*rand(np,1) + wv+1;
        end
        [~, idx] = sort(xv+yv*nx); % sort spots according to row position
        xv = xv(idx);
        yv = yv(idx);
    end
else
    if ~isempty(xv) && (any(min([xv; yv])<0.5) || any(max(xv)>=nx+0.5) || any(max(yv)>=ny+0.5))
        error('All points must lie within x:[0.5 nx+0.5), y:[0.5 ny+0.5).');
    end
    if isempty(xv)
        if ip.Results.NonOverlapping
            xv = [];
            yv = [];
            while numel(xv)<np
                xcand = nx*rand(np,1)+0.5;
                ycand = ny*rand(np,1)+0.5;
                idx = KDTreeBallQuery([xcand ycand; xv yv], [xcand ycand], 2*wv);
                idx(cellfun(@numel, idx)>1) = [];
                idx = vertcat(idx{:});
                xv = [xv; xcand(idx)]; %#ok<AGROW>
                yv = [yv; ycand(idx)]; %#ok<AGROW>
            end
            xv = xv(1:np);
            yv = yv(1:np);
        else
            xv = nx*rand(np,1)+0.5;
            yv = ny*rand(np,1)+0.5;
        end
    end
end

% background image
frame = c*ones(ny, nx);

xi = round(xv);
yi = round(yv);
dx = xv-xi;
dy = yv-yi;

if strcmpi(ip.Results.Normalization, 'analytical')
    Av = Av ./ (2*pi*sv.^2);
end

switch ip.Results.Border
    case 'padded'
        for k = 1:np
            wi = wv(k);
            xa = xi(k)-wi:xi(k)+wi;
            ya = yi(k)-wi:yi(k)+wi;
            [xg,yg] = meshgrid(-wi:wi);
            g = exp(-((xg-dx(k)).^2+(yg-dy(k)).^2) / (2*sv(k)^2));
            if strcmpi(ip.Results.Normalization, 'sum')
                g = Av(k)*g/sum(g(:));
            else
                g =  Av(k)*g;
            end
            frame(ya,xa) = frame(ya,xa) + g;
        end
    case 'periodic'
        lbx = xi-wv;
        ubx = xi+wv;
        lby = yi-wv;
        uby = yi+wv;
        
        for k = 1:np
            shifts = [0 0];
            if lbx(k)<1
                shifts(2) = 1-lbx(k);
            elseif ubx(k)>nx
                shifts(2) = nx-ubx(k);
            end
            if lby(k)<1
                shifts(1) = 1-lby(k);
            elseif uby(k)>ny
                shifts(1) = ny-uby(k);
            end
            wi = -wv(k):wv(k);
            [xg,yg] = meshgrid(wi,wi);
            g = exp(-((xg-dx(k)).^2+(yg-dy(k)).^2) / (2*sv(k)^2));
            if strcmpi(ip.Results.Normalization, 'sum')
                g = Av(k)*g/sum(g(:));
            else
                g =  Av(k)*g;
            end
            xa = (xi(k)-wv(k):xi(k)+wv(k)) + shifts(2);
            ya = (yi(k)-wv(k):yi(k)+wv(k)) + shifts(1);
            if all(shifts==0)
                frame(ya,xa) = frame(ya,xa) + g;
            else
                frame = circshift(frame, shifts);
                frame(ya,xa) = frame(ya,xa) + g;
                frame = circshift(frame, -shifts);
            end
        end
    case 'truncated'
        lbx = max(xi-wv,1);
        ubx = min(xi+wv,nx);
        lby = max(yi-wv,1);
        uby = min(yi+wv,ny);
        
        for k = 1:np
            wx = (lbx(k):ubx(k)) - xi(k);
            wy = (lby(k):uby(k)) - yi(k);
            [xg,yg] = meshgrid(wx,wy);
            g = exp(-((xg-dx(k)).^2+(yg-dy(k)).^2) / (2*sv(k)^2));
            if strcmpi(ip.Results.Normalization, 'sum')
                g = Av(k)*g/sum(g(:));
            else
                g =  Av(k)*g;
            end
            xa = lbx(k):ubx(k);
            ya = lby(k):uby(k);
            frame(ya,xa) = frame(ya,xa) + g;
        end
end
