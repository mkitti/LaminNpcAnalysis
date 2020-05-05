function time =testKDTreeClosestPoint(varargin)
% testKDTreeClosestPoint benchmarks the KDTreeClosestPoint function.
%
% [idx, dist] = testKDTreeClosestPoint(nInPts,nQueryPts)
% [idx, dist] = testKDTreeClosestPoint(nInPts,nQueryPts,dim,'N',N)
% 
% This function create two random input and query arrays of size
% (nInptsxdimxN) and (nQueryPtsxdimxN). Each set of input/query points is
% tested using KDTreeClosestPoint and createDistanceMatrix, the equality
% of the results is checked and the processing time is returned
%
% Input:
% 
%     ninPts - Optional - The number of input points to be generated.
% 
%     nQueryPts - Optional- The number of query points to be generated.
%
%     dim - Optional- The dimension of the points.
%
%     N - Parameter/value pair - The number of iterations of the test
% 
% Output:
% 
%   time - a Nx2 matrix returning the time of the KDTreeClosestPoint and of
%   the createDistance Matrix for each iteration.
%
% See KDTreeClosestPoint.m for details.
%
% Sebastien Besson, Oct 2011 (last modified Nov 2011)

% Generate random input and query points
ip =inputParser;
ip.addOptional('nInPts',1e4,@isscalar);
ip.addOptional('nQueryPts',1e4,@isscalar);
ip.addOptional('dim',3,@(x) isscalar(x) || ismember(x,1:3));
ip.addParamValue('N',100,@isscalar);
ip.parse(varargin{:});
nInPts = ip.Results.nInPts;
nQueryPts = ip.Results.nQueryPts;
dim = ip.Results.dim;
N= ip.Results.N;


% Using KDTreeClosestPoint
if feature('ShowFigureWindows')
    fprintf(['Running %d repetitions of KDTreeClosestPoint and createDistanceMatrix'...
        'for %d input points and %d query points of dimension %d\n'],...
        N,nInPts,nQueryPts,dim);
end

fullTestClock = tic;

% Initialize time output
time1 = zeros(N,1);
time2 = zeros(N,1);
parfor i=1:ip.Results.N
    % Initialize input and query points
    X = rand(nInPts,dim);
    C = rand(nQueryPts,dim);
    
    KDTreeClock = tic;
    [idx,d] = KDTreeClosestPoint(X,C);
    time1(i)=toc(KDTreeClock);
    
    distanceMatrixClock = tic;
    D = createDistanceMatrix(X,C);
    [d2,idx2] = min(D,[],1);
    time2(i)=toc(distanceMatrixClock);
    
    assert(all(idx(:)==idx2(:)));
    assert(all(d(:)==d2(:)))
end
time = [time1 time2];
toc(fullTestClock)
