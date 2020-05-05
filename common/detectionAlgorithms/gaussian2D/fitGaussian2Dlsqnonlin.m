function [prmVect, prmStd, C, res, J] = fitGaussian2Dlsqnonlin(data, prmVect, mode, mask, xa, ya)
%[prmVect, G] = fitGaussian2D(data, p, mode)
%
% Input: data: 2-D image array
%        p      : [xp yp A sigma c] initial and fixed parameter values
%        {mode} : specifies which parameters to estimate; any combination of 'xyAsc'
%        {mask} : elements set to 1 are not included in optimization
%        {xa}   : x-axis
%        {ya}   : y-axis
%
% Axis convention: see meshgrid
%
% Data is assumed to contain a single spot
%
% Francois Aguet, last modified May 2010

if nargin<3
    mode = 'xyAsc';
end
if nargin<4
    mask = [];
end
if nargin<5
    if (size(data,1) ~= size(data,2)) || ~mod(size(data,1),2)
        error('Input must be square with odd side length in this mode.');
    end
    w = (size(data,1)-1)/2;
    xa = -w:w;
    ya = xa;
elseif nargin<6
    ya = xa;
end


opts = optimset('Jacobian', 'on', ...
    'MaxFunEvals', 1e4, ...
    'MaxIter', 1e4, ...
    'Display', 'off', ...
    'TolX', 1e-8, ...
    'Tolfun', 1e-8);%,...
    %'Algorithm', 'levenberg-marquardt');


estIdx = false(1,5); % [x y A s c]
estIdx(regexpi('xyAsc', ['[' mode ']'])) = true;
lb = [xa(1) ya(1) 0 0 0];
ub = [xa(end) ya(end) Inf Inf Inf];

[y,x] = ndgrid(ya, xa);
if sum(estIdx)==1 && estIdx(3)==1
    prmVect = A_CF_Gaussian(data, x, y, prmVect);
else
    [p, resnorm, res, ~, ~, ~, J] = lsqnonlin(@costGaussian, prmVect(estIdx), lb(estIdx), ub(estIdx), opts, data, x, y, prmVect, estIdx, mask);
    %[p, ~, res, ~, ~, ~, J] = lsqnonlin(@costGaussian, prmVect(estIdx), [], [], opts, data, x, y, prmVect, estIdx, mask);
    prmVect(estIdx) = p;
end

sigma2 = resnorm / (numel(data) - sum(estIdx) - 1);
J = full(J);
C = inv(J'*J);
prmStd = sqrt(sigma2*diag(C));




function [v, J] = costGaussian(p, data, x, y, prmVect, estIdx, mask)
prmVect(estIdx) = p;

[g J] = gaussian2D(x, y, prmVect);
J(:,estIdx==false) = []; % remove unneeded Jacobian components
v = g - data;
maskIdx = mask==1;
v(maskIdx) = [];
J(maskIdx, :) = [];


function [g J] = gaussian2D(x, y, prmVect)

tmp = num2cell(prmVect);
[xp yp A s c] = deal(tmp{:});

r2 = (x-xp).^2+(y-yp).^2;

g_dA = exp(-r2/(2*s^2));
g = A*g_dA;

g_dxp = (x-xp)./s^2.*g;
g_dyp = (y-yp)./s^2.*g;
g_ds = r2/s^3.*g;
g = g + c;

N = numel(x);
g_dc = ones(N,1);
J = [reshape(g_dxp, [N 1]) reshape(g_dyp, [N 1]) reshape(g_dA, [N 1]) reshape(g_ds, [N 1]) g_dc];


function prmVect = A_CF_Gaussian(data, x, y, prmVect)
r2 = (x-prmVect(1)).^2+(y-prmVect(2)).^2;
g_dA = exp(-r2/(2*prmVect(4)^2));
prmVect(3) = sum(sum((data-prmVect(5)).*g_dA)) / sum(sum(g_dA.^2));
