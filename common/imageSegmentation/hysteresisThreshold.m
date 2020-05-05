%out = hysteresisThreshold(img, t1, t2) performs hysteresis thresholding.
%
% Inputs:  img : input image
%           t1 : high threshold
%           t2 : low threshold
%
% Outputs: out : binary mask

% Francois Aguet, June 30, 2010

function out = hysteresisThreshold(img, t1, t2,nHood)

if nargin < 4 || isempty(nHood)
    nHood = 8;
end

labels = bwlabel(img>=t2, nHood);

labelsAboveT1 = labels;
labelsAboveT1(img<t1) = 0;

validLabels = unique(labelsAboveT1(:));
validLabels = validLabels(2:end);

out = ismember(labels, validLabels);