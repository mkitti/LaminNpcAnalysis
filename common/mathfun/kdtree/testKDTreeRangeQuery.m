function testKDTreeRangeQuery
% This function test the KDTreeRangeQuery.
%
% See KDTreeRangeQuery.m for details.
%
% Sylvain Berlement
% Sebastien Besson, Oct 2011

% Generate random input and query points
dim=2;
nInPts= 1000000;
nQueryPts =100;
X = rand(nInPts,dim);
C = [[.5 .5]; rand(nQueryPts-1,2)];
L = repmat([.4 .6],[nQueryPts 1]);

fprintf('Running KDTreeRangeQuery for %d input points and %d query points of dimension %d\n',...
    nInPts,nQueryPts,dim);
tic;
idx = KDTreeRangeQuery(X,C,L);
toc

plot(X(:,1),X(:,2), 'b.');
hold on;
plot(C(1,1) + L(1,1)/2*[-1 -1 1 1 -1],C(1,2) + L(1,2)/2*[1 -1 -1 1 1], 'g-');
plot(X(idx{1},1), X(idx{1},2), 'r.');
axis equal