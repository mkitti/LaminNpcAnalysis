function ptInd = getSelectedPointIndex(figHan,ptData,dcm)
%GETSELECTEDPOINTINDEX get index of point(s) selected in a plot with the data cursor
%
%  ptInd = getSelectedPointIndex;
%  ptInd = getSelectedPointIndex(figHan,ptData)
%  ptInd = getSelectedPointIndex([],ptData,dataCursorObj)
%
% Hunter Elliott
% 5/2013

if nargin > 2 && ~isempty(dcm)
    dcInfo = dcm.getCursorInfo;
else
    
    if nargin < 1 || isempty(figHan)
        figHan = gcf;
    end
    
    dcm = datacursormode(figHan);
    dcInfo = dcm.getCursorInfo;
end

if isfield(dcInfo,'DataIndex')
    
    ptInd = vertcat(dcInfo(:).DataIndex);
    
elseif nargin < 2 || isempty(ptData)
    error('Please input the plotted data = this plot type does not support automatic index return!')    
else
   selX = vertcat(dcInfo(:).Position);
   wrnStat = warning('query','KDTREE:closestPtBuild');%Get current warning status
   warning('off','KDTREE:closestPtBuild');%Disable this annoying warning
   ptInd = KDTreeClosestPoint(ptData,selX);
   warning(wrnStat.state,'KDTREE:closestPtBuild');%Return to original state   
end

