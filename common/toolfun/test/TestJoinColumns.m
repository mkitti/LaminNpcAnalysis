classdef TestJoinColumns < TestCase
    properties
        matrices
    end
    methods
        function self = TestJoinColumns(varargin)
            self = self@TestCase(varargin{:});
        end
        function setUp(self)
            self.matrices{1} = magic(5);
            self.matrices{2} = randn(1);
            self.matrices{3} = randi(5,5,'uint8');
            self.matrices{4} = 'hello';
        end
        function tearDown(self)
            self.matrices = {};
        end
        function checkJoin(self, delimeter, matrices, result)
            if(~isempty(delimeter))
                % add delimeter to the end since we truncate it
                for i=1:length(result)
                    result{i}(end+1,1) = delimeter;
                end
            end
            nCols = cellfun('size',result,2);
            assertEqual(nCols,ones(size(result)));
            resultNumEl = cellfun('prodofsize',result);
            nCols = cellfun('size',matrices,2);
            nRows = cellfun('size',matrices,1);
            if(isempty(delimeter))
                assertEqual(resultNumEl,nCols.*(nRows));
            elseif(~iscell(delimeter) && isnan(delimeter))
                [out{1:2}] = cellfun(@(r,n) deal(find(isnan(r))',n:n:length(r)),result,num2cell(nRows+1),'UniformOutput',false);
                assertEqual(out{1},out{2});
            else
                assertEqual(resultNumEl,nCols.*(nRows+1));
                delims = cellfun(@(r,n) unique(r(n:n:end)),result,num2cell(nRows+1));
                assertEqual(delims,repmat(delimeter,size(delims)));
            end
        end
        function testEmptyDelimeter(self)
            [r{1:length(self.matrices)}] = joinColumns([],self.matrices{:});
            self.checkJoin([],self.matrices,r);
        end
        function testNoDelimeter(self)
            [r{1:length(self.matrices)}] = joinColumns(self.matrices{:});
            self.checkJoin([],self.matrices,r);
        end
        function testReal(self)
            [r{1:2}] = joinColumns(pi,self.matrices{:});
            self.checkJoin(pi,self.matrices(1:2),r);
        end
        function testNaN(self)
            [r{1:2}] = joinColumns(NaN,self.matrices{1:2});
            self.checkJoin(NaN,self.matrices(1:2),r);
        end
        function testCell(self)
            r = joinColumns({'a'},num2cell(self.matrices{4}));
            self.checkJoin({'a'},{num2cell(self.matrices{4})},{r});
        end
    end
end