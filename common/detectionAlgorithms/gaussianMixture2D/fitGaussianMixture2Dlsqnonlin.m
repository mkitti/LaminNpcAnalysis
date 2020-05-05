function [prmVect, prmStd, C, res, J] = fitGaussianMixture2Dlsqnonlin(data, prmVect, mode, mask, xa, ya)
%[prmVect, G] = fitGaussian2D(data, p, mode)
%
% Input: data: 2-D image array
%        p      : [xp1 yp1 A1 ... xpn ypn An sigma c] initial and fixed parameter values
%        {mode} : specifies which parameters to estimate; any combination of 'xyAsc'
%        {mask} : elements set to 1 are not included in optimization
%        {xa}   : x-axis
%        {ya}   : y-axis
%
% Axis convention: see meshgrid
%
% Francois Aguet, June 2012

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
    'TolX', 1e-10, ...
    'Tolfun', 1e-10,...
    'Algorithm', 'levenberg-marquardt');


ng = (numel(prmVect)-2)/3;

estIdx = false(1,5);
estIdx(regexpi('xyAsc', ['[' mode ']'])) = true;
estIdx = [repmat(estIdx(1:3), [1 ng]) estIdx(4:5)];
lb = [repmat([xa(1) ya(1) -Inf], [1 ng]) 0 0];
ub = [repmat([xa(end) ya(end) Inf], [1 ng]) Inf Inf];

[x,y] = meshgrid(ya, xa);
% [p, resnorm, res, ~, ~, ~, J] = lsqnonlin(@costGaussian, prmVect(estIdx), lb(estIdx), ub(estIdx), opts, data, x, y, prmVect, estIdx, mask);
[p, resnorm, res, ~, ~, ~, J] = lsqnonlin(@costGaussian, prmVect(estIdx), [], [], opts, data, x, y, prmVect, estIdx, mask);
prmVect(estIdx) = p;

sigma2 = resnorm / (numel(data) - sum(estIdx) - 1);
J = full(J);
C = inv(J'*J);
prmStd = sqrt(sigma2*diag(C));




function [v, J] = costGaussian(p, data, x, y, prmVect, estIdx, mask)
prmVect(estIdx) = p;
[g J] = gaussianMixture2D(x, y, prmVect);
v = g - data;

J(:,estIdx==false) = []; % remove unneeded Jacobian components
maskIdx = mask(:)==1;
v(maskIdx) = [];
J(maskIdx, :) = [];



% x,y are coordinate grids
function [g J] = gaussianMixture2D(x, y, prmVect)
ng = (numel(prmVect)-2)/3;
xp = prmVect(1:3:end-2);
yp = prmVect(2:3:end-2);
A = prmVect(3:3:end-2);
s = prmVect(end-1);
c = prmVect(end);

g = c*ones(size(x));
N = numel(x);
J = zeros(N,numel(prmVect));
for i = 1:ng
    r2 = (x-xp(i)).^2+(y-yp(i)).^2;
    ig = exp(-r2/(2*s^2));
    g = g + A(i)*ig;
    J(:,(i-1)*3+1) = A(i)*ig(:).*(x(:)-xp(i))/s^2;
    J(:,(i-1)*3+2) = A(i)*ig(:).*(y(:)-yp(i))/s^2;
    J(:,(i-1)*3+3) = ig(:);
    tmp = A(i)*ig.*r2/s^3;
    J(:,end-1) = J(:,end-1) + tmp(:);
end
J(:,end) = ones(N,1);
