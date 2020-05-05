function testKDTreeBallQuery
% This function test the KDTreeBallQuery.
%
% See KDTreeBallQuery.m for details.
%
% Sylvain Berlement
% Sebastien Besson, Oct 2011

% Generate random input and query points
dim=2;
nInPts= 10000;
nQueryPts =1000;
X = rand(nInPts,dim);
C = [[.5 .5]; rand(nQueryPts-1,2)];
R = .2;

fprintf('Running KDTreeBallQuery for %d input points and %d query points of dimension %d\n',...
    nInPts,nQueryPts,dim);
tic
[idx,d] = KDTreeBallQuery(X,C,R);
toc

assert(all(cellfun(@(x) all(x <= R),d)));

plot(X(:,1),X(:,2), 'b.');
hold on;
t = 0:pi/100:2*pi;
plot(C(1,1) + R * cos(t),C(1,2) + R * sin(t), 'g-');
plot(X(idx{1},1), X(idx{1},2), 'r.');
axis equal;