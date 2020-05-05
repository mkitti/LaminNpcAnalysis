function [ mode,sigma,normFactor ] = analyzeNPCHistogram( uniformData, actualData )
%analyzeNPCHistogram Analyze NPC histogram data
%
% INPUT
% uniformData
% actualData
%
% OUTPUT
%

binWidth = 10;
binStart = 0;
binEnd   = 300;
bins = binStart:binWidth:binEnd;

if(isstruct(uniformData) && nargin == 1)
    actualData = uniformData.adata_all;
    uniformData = uniformData.udata_all;
end

actualHist = histcounts(actualData,bins,'Normalization','probability');
uniformHist = histcounts(uniformData,bins,'Normalization','probability');

ratio = actualHist./uniformHist;
weights = uniformHist;
binCenters = bins(1:end-1)+binWidth/2;

% a1*exp( -((x-b1)/c1)^2 )
fitType = fittype('gauss1');
fitSolution = fit(binCenters.',ratio.',fitType,'Weights',weights.','Lower',[0 0 0]);

mode = fitSolution.b1;
sigma = fitSolution.c1/sqrt(2);
normFactor = fitSolution.a1;

if(nargout == 0)
    figure;
    plot(binCenters,ratio,'.');
    hold on;
    plot(fitSolution);
    grid on;
    
    figure;
    gaussRatio = feval(fitSolution,binCenters);
    histogram(uniformData,bins,'Normalization','probability');
    hold on;
    histogram(actualData,bins,'Normalization','probability');
    plot(binCenters,uniformHist.*gaussRatio.','r-','MarkerEdgeColor','k','Marker','.');
    annotation('textArrow',[mode normFactor]/300,[mode+50 normFactor]/300,'String',['mode = ' num2str(mode)]);
end

end

