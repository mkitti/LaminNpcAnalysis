function psf = psf2D(pixelSize, NA, lambda)

%PSF2D generates a 2-D point spread function (Airy disc)
%
% SYNOPSIS psf = psf2D(pixelSize, NA, lambda)
%
% INPUT    pixelSize : pixel size in object space (in um)
%          NA      : numerical aperture of the objective lens
%          lambda  : wavelength of light (in um)
%
% OUTPUT   psf       : filter mask (odd dimensions) representing the Airy disk
%                      the filter is normalized to sum(psf(:)) = 1 
%
% NOTE     the function calculates the Airy disk radius according to 
%          R0 = 0.61 * lambda / NA
%          
% Alexandre Matov, January 7th, 2003
% Francois Aguet, 11/02/2009

%bessel1_zero1 = 3.8317059702075;
bessel1_zero2 = 7.0155866698156;

z0 = 2*pi/lambda*NA;

%R0 = bessel1_zero1 / z0;
R1 = bessel1_zero2 / z0;

b = ceil(R1/pixelSize);
[x,y] = meshgrid(-b:b);

z = sqrt(x.^2 + y.^2) * pixelSize * z0;

psf = besselj(1,z) ./ z;
psf = psf .* conj(psf);
psf(b+1,b+1) = 0.25; % limit at J_1(0)/0

psf = psf / sum(psf(:));