
% window width
w = 5;

% parameters of 3 gaussians
xp1 = 0.4;
yp1 = 0.3;
A1 = 7;

xp2 = -2.1;
yp2 = -3.25;
A2 = 5;

xp3 = 1;
yp3 = 1;
A3 = 8;

% std dev. and background same for all
sigma = 1.6;
b = 4;

[x,y] = meshgrid(-w:w);

r2 = (x-xp1).^2+(y-yp1).^2;
g1 = exp(-r2/(2*sigma^2));

r2 = (x-xp2).^2+(y-yp2).^2;
g2 = exp(-r2/(2*sigma^2));

r3 = (x-xp3).^2+(y-yp3).^2;
g3 = exp(-r3/(2*sigma^2));



% h = A1*g1 + A2*g2 + A3*g3 + b;
h = A1*g1 + A2*g2 + b;
% h = A1*g1 + b;
% h = A2*g2 + b;


N = numel(h);

psnr = 25;
c = 10^(psnr/10) * sum(h(:))/N / max(h(:)-b)^2;

q = addPoissonNoise(h, c);
% q = h + 5*randn(size(h));


%%
[prmVect prmStd C res J] = fitGaussianMixture2D(h, [1 1 5 0 0 5 1.6 0], 'xyAc');
prmVect

%%
[prmVect,~,~,~,Jref] = fitGaussianMixture2Dlsqnonlin(h, [0 0 5 0 0 5 1.6 0], 'xyAc');
prmVect


%%
frame = h;


% initial parameter guess (1 model)
prmVect0 = [0 0 max(frame(:))-min(frame(:)) 1.6 min(frame(:))];
[prmVect prmStd C res J] = fitGaussianMixture2D(frame, prmVect0, 'xyAc');
RSS_r = res.RSS;
p_r = 4;

nmax = 4;
pval = 1;
i = 1;
while i<nmax && pval>0.95
    i = i+1;
    % expanded model
    % new component: initial values given by max. residual point
    [x0 y0] = ind2sub(size(h), find(RSS_r==max(RSS_r(:)),1,'first'));
    prmVect0 = [x0 y0 max(res.data(:)) prmVect0];
    [prmVect prmStd C res J] = fitGaussianMixture2D(frame, prmVect0, 'xyAc');
    RSS_f = res.RSS;
    p_f = p_r + 3;
    
    % test statistic
    T = (RSS_r-RSS_f)/RSS_f * (N-p_f-1)/(p_f-p_r);
    pval = fcdf(T,p_f-p_r,N-p_f-1)

    % update reduced model
    p_r = p_f;
    RSS_r = RSS_f;
end
