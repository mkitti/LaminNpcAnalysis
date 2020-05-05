classdef TestInputParserRetrofit < TestCase
    properties
        ipr
        Results
    end

    methods
        function self = TestInputParserRetrofit(varargin)
            self = self@TestCase(varargin{:});
        end
        function setUp(self)
            s.opt1 = 0;
            s.opt2 = false;
            s.arg1 = 'asdfljAsd';
            s.arg2 = struct('a',1);
            s.arg3 = 1:5;
            p = inputParserRetrofit;
            p.addRequired('req1',@isscalar);
            p.addRequired('req2',@isnumeric);
            p.addOptional('opt1',s.opt1,@isnumeric);
            p.addOptional('opt2',s.opt2,@islogical);
            p.addArgument('arg1',s.arg1,@ischar);
            p.addArgument('arg2',s.arg2,@isstruct);
            p.addArgument('arg3',s.arg3,@isnumeric);
            self.ipr = p;
            self.Results = s;
        end
        function tearDown(self)
        end
        function testRequired(self)
            R = self.Results;
            R.req1 = 5;
            R.req2 = 1:5;
            p = self.ipr;
            p.parse(R.req1,R.req2);
            assertEqual(p.Results,R);
        end
        function testOptional(self)
            R = self.Results;
            R.req1 = 6;
            R.req2 = [10 12];
            R.opt1 = 1;
            p = self.ipr;
            p.parse(R.req1, R.req2, R.opt1);
            assertEqual(p.Results,R);
            R.opt2 = true;
            p.parse(R.req1, R.req2, R.opt1, R.opt2);
            assertEqual(p.Results,R);
        end
        function testParameterMode(self)
            R = self.Results;
            R.req1 = 6;
            R.req2 = [10 12];
            R.arg2 = struct('xCoords',1:5,'yCoords',9:15);
            p = self.ipr;
            p.parse(R.req1,R.req2,'arg2',R.arg2);
            assert(~p.useOptions);
            assertEqual(p.Results,R);
            R.arg1 = 'c';
            R.arg3 = 1:5;
            R.opt1 = [pi 12345];
            p.parse(R.req1,R.req2,R.opt1,'arg2',R.arg2,'arg1',R.arg1,'arg3',R.arg3);
            assertEqual(p.Results,R);
            assert(~p.useOptions);
        end
        function testOptionsMode(self)
            R = self.Results;
            R.req1 = 6;
            R.req2 = [10 12];
            R.arg2 = struct('xCoords',1:5,'yCoords',9:15);
            p = self.ipr;
            p.parse(R.req1,R.req2,R.opt1,R.opt2,R.arg1,R.arg2,R.arg3);
            assert(p.useOptions);
            assertEqual(p.Results,R);
            p.parse(R.req1,R.req2,[],[],[],R.arg2,[]);
            assert(p.useOptions);
            assertEqual(p.Results,R);
        end
        function testReadOnlyProperties(self)
            R = self.Results;
            R.req1 = 5;
            R.req2 = 1:5;
            p = self.ipr;
            params = p.Parameters;
            assertEqual(sort(params),sort(fieldnames(R)'));
            results = p.Results;
            unmatched = p.Unmatched;
            defaults = p.UsingDefaults;
        end
        function testSetProperties(self)
            p = self.ipr;
            p.CaseSensitive = false;
            p.FunctionName = 'helloWorld';
            p.KeepUnmatched = true;
            p.PartialMatching = false;
            p.StructExpand = false;
        end
        function testResultRetrieval(self)
            p = self.ipr;
            R = self.Results;
            R.req1 = Inf;
            R.req2 = 3;
            p.parse(R.req1,R.req2,R);
            p.Results.opt1;
            assertEqual(p.Results,R);
            assertEqual(p.Results.req1,R.req1);
            assertEqual(p.Results.arg1,R.arg1);
            assertEqual(p.Results.opt1,R.opt1);
        end
        function testUnmatched(self)
            p = self.ipr;
            R = self.Results;
            R.req1 = 90;    
            R.req2 = pi;
            p.KeepUnmatched = true;
            newStruct.unknown1 = 5;
            newStruct.unknown2 = 6;
            p.parse(R.req1,R.req2,R,newStruct);
            assertEqual(p.Results,R);
            assertEqual(p.Unmatched,newStruct);
        end
    end
end
