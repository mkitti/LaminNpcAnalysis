% Test the difference between the psf sigma obtained from the vectorial psf
% model and the approximation of the psf as a Bessel function

% Sebastien Besson, June 2011 (last modified July 2011)

% Clear the workspace
clear
clc
close all

% define small and large fonts for graphical output
tfont = {'FontName', 'Helvetica', 'FontSize', 14, 'FontAngle', 'italic'};
sfont = {'FontName', 'Helvetica', 'FontSize', 18};
lfont = {'FontName', 'Helvetica', 'FontSize', 22};

%% Test variations of psf sigma as a function of wavelength and NA
% Constant parameters
pixelSize=100e-9;
M=1;

% Parameters sweep
n = 21; % Number of parameters
lambda_min=300e-9;
lambda_max=800e-9;
NA_min = .5;
NA_max = 1.5;
lambda = @(x) lambda_min+(x-1)*(lambda_max-lambda_min)/(n-1);
NA = @(x) NA_min+(x-1)*(NA_max-NA_min)/(n-1);

% Calculate psf sigma
sigma_vectorialPSF = zeros(n,n);
sigma_besselPSF = zeros(n,n);
for index=1:n^2    
    [i,j]=ind2sub([n,n],index);
    sigma_vectorialPSF(i,j) = getGaussianPSFsigma(NA(i),M,pixelSize,lambda(j));
    sigma_besselPSF(i,j) = calcFilterParms(lambda(j),NA(i),1.518,'gauss',[1 1],[pixelSize pixelSize]);
end
dsigma= (sigma_vectorialPSF-sigma_besselPSF)./(sigma_besselPSF);

% Plot results
figure('PaperPositionMode', 'auto','Position',[50 50 500 500]); % enable resizing
hold on;
[C,h] = contour(NA(1:n),lambda(1:n)*1e9,dsigma','LineWidth',2);
hText = clabel(C,h);
set(hText,tfont{:})
axis square

% Set thickness of axes, ticks and assign tick labels
box on
set(gca, 'LineWidth', 1.5, sfont{:}, 'Layer', 'top');
xlabel('Numerical aperture', lfont{:});
ylabel('Wavelength (nm)', lfont{:});
set(gca,'LooseInset',get(gca,'TightInset'))

%% Test variations of psf sigma as a function of pixel size and magnification
% Constant parameters
lambda= 300e-9;
NA=1;

% Parameters sweep
n = 8; % Number of parameters
pixelSize_min=2e-6;
pixelSize_max=14e-6;
M_min = 40;
M_max = 150;
pixelSize = @(x) pixelSize_min+(x-1)*(pixelSize_max-pixelSize_min)/(n-1);
M = @(x) M_min+(x-1)*(M_max-M_min)/(n-1);

% Calculate sigma
sigma_vectorialPSF = zeros(n,n);
sigma_besselPSF = zeros(n,n);
for index=1:n^2    
    [i,j]=ind2sub([n,n],index);
    sigma_vectorialPSF(i,j) = getGaussianPSFsigma(NA,M(j),pixelSize(i),lambda);
    sigma_besselPSF(i,j) = calcFilterParms(lambda,NA,1.518,'gauss',[1 1],[pixelSize(i) pixelSize(i)]/M(j));
end
dsigma= (sigma_vectorialPSF-sigma_besselPSF)./(sigma_besselPSF);

% plot
figure('PaperPositionMode', 'auto','Position',[50 50 500 500]); % enable resizing
hold on;
[C,h] = contour(pixelSize(1:n)*1e6,M(1:n),dsigma','LineWidth',2);
hText = clabel(C,h);
set(hText,tfont{:})
axis square

% Set thickness of axes, ticks and assign tick labels
box on
set(gca, 'LineWidth', 1.5, sfont{:}, 'Layer', 'top');
xlabel('Pixel Size (microns)', lfont{:});
ylabel('Magnification', lfont{:});
set(gca,'LooseInset',get(gca,'TightInset'))
