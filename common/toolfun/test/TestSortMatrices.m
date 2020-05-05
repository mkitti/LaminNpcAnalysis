classdef TestSortMatrices < TestCase
    properties
        A
        B
    end
    methods
        function self = TestSortMatrices(name)
            self = self@TestCase(name);
            self.A = randi(1024,30);
            self.B = randi(1024,30);
        end
        function testSort(self)
            sA = sortMatrices(self.A);
            assertEqual(sA,sort(self.A));
        end
        function testIndices(self)
            [~,I] = sortMatrices(self.A);
            assertEqual(self.A(I),sort(self.A));
        end
        function testOtherMatrix(self)
            [~,rB,I] = sortMatrices(self.A,self.B);
            assertEqual(rB,self.B(I));
        end
        function testDimension(self)
            [sA,rB,I] = sortMatrices(self.A,self.B,2);
            assertEqual(sA,sort(self.A,2));
        end
        function testMode(self)
            [sA] = sortMatrices(self.A,self.B,1,'descend');
            assertEqual(sA,sort(self.A,1,'descend'));
            [sA] = sortMatrices(self.A,self.B,1,'ascend');
            assertEqual(sA,sort(self.A,1,'ascend'));
        end
        function testTextSort(self)
            [sA,sB,sC] = sortMatrices('Hello','Guten','Hola!','descend');
            assertEqual(sA,sort('Hello','descend'));
        end
    end
end