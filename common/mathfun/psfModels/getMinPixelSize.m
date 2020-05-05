%[px] = getMinPixelSize(sigma, lambda) calculates the mininum pixel size
% required to obtain a Gaussian PSF approximation with SD = sigma, given 
% wavelength lambda. Units are in [m].

% Francois Aguet, October 2010

function [px] = getMinPixelSize(sigma, lambda)

ru = ceil(4*sigma);
[x,y] = meshgrid(-ru+1:ru-1);
G = exp(-(x.^2+y.^2)/(2*sigma^2));

p.ti0 = 0.19e-3;
p.ni0 = 1.518;
p.ni = 1.518;
p.tg0 = 0.17e-3;
p.tg = 0.17e-3;
p.ng0 = 1.515;
p.ng = 1.515;
p.ns = 1.33;
p.lambda = lambda;
p.M = 100;
p.NA = 1.49;

opts = optimset('Jacobian', 'off', ...
    'MaxFunEvals', 1e4, ...
    'MaxIter', 1e4, ...
    'Display', 'off', ...
    'TolX', 1e-8, ...
    'Tolfun', 1e-8);

prm = lsqnonlin(@costFct, [5e-6 10], [0 0], [15e-6 Inf], opts);
px = prm(1);

    function v = costFct(prm)
        p.pixelSize = prm(1);        
        psf = vectorialPSF([0 0 0], 0, (2*ru)-1, p);
        v = psf - prm(2)*G;
    end
end
