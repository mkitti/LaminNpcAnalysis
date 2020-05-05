classdef TestKDTree < TestCase
    
    properties
        nInPts = 10^4;
        nQueryPts = 10^2
    end
    methods
        function self = TestKDTree(name)
            self = self@TestCase(name);
        end
        
        function testBallQueryRadius(self)
            for dim=1:3,
                X = rand(self.nInPts,dim);
                C = rand(self.nQueryPts,dim);
                R=.2;
                idx = KDTreeBallQuery(X,C,R);
                idx2 = KDTreeBallQuery(X,C,R*ones(self.nQueryPts,1));
                assertEqual(idx, idx2)
            end
        end
        
        
        function testRandBallQuery(self)
            for dim=1:3,
                X = rand(self.nInPts,dim);
                C = rand(self.nQueryPts,dim);
                R = .2;
                [~,d] = KDTreeBallQuery(X,C,R);
                assertTrue(all(vertcat(d{:})<=R));
            end
        end
        
        function testRandRangeQuery(self)
            for dim=1:3,
                X = rand(self.nInPts,dim);
                C = rand(self.nQueryPts,dim);
                R = .2*ones(self.nQueryPts,dim);
                [~,d] = KDTreeRangeQuery(X,C,R);
                assertTrue(all(vertcat(d{:})<=R(1)));
            end
        end
        
        function testRandClosestPoint(self)
            for dim=1:3,
                X = rand(self.nInPts,dim);
                C = rand(self.nQueryPts,dim);
                [idx,d] = KDTreeClosestPoint(X,C);
                D = createDistanceMatrix(X,C);
                [d2,idx2] = min(abs(D),[],1);
                
                assertEqual(idx,idx2');
                assertEqual(d,d2')
            end
        end   
        
        %% Subsampling algorithm
        function testKDTreeSubsampling(self)
            X = rand(self.nInPts,2);
            for D= [.01 .05 .1 .2]
                idx = KDTreeBallQuery(X,X,D);
                
                valid = true(numel(idx),1);
                for i = 1:numel(idx)
                    if ~valid(i), continue; end
                    neighbors = idx{i}(idx{i}~=i);
                    valid(neighbors) = false;
                end
            
                idx2 = KDTreeBallQuery(X(valid,:),X(valid,:),D);
                assertTrue(all(cellfun(@numel,idx2)==1));
            end
        end  
        
        %% Sparse distance matrix tests
        function testCreateSparseDistanceMatrix(self)
            
            for dim=1:3
                X = rand(100, dim);
                allDist=createDistanceMatrix(X, X);
                sp=createSparseDistanceMatrix(X, X,1);
                assertVectorsAlmostEqual(find(allDist<1), find(sp));
            end
        end 
        
        function testCreateSparseDistanceMatrixwithNaNs(self)
            
            for dim=1:3
                X = rand(100, dim);
                X([10 50 80],:) = NaN;
                allDist=createDistanceMatrix(X, X);
                sp=createSparseDistanceMatrix(X, X,1);
                assertVectorsAlmostEqual(find(allDist<1), find(sp));
            end
        end 
    end
end
