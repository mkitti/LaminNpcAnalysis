classdef TestParCellfun_progress < TestCase
    %TestParCellfun_progress Tests function pararrayfun_progress
    properties
        % parallel.pool object to clean up on delete
        pool
        % sample inputs
        A
        B
        % parallel fucntion
        func
        % Use nonparfunc for comparison so we can run the same tests for
        % cellfun and arrayfun
        nonparfunc
    end
    methods
        function self = TestParCellfun_progress(name)
            self = self@TestCase(name);
            self.func = @(varargin) parcellfun_progress(varargin{:},'DisplayFunc',@(d) 0);
            self.nonparfunc = @cellfun;
        end
        function setUp(self,A,B)
            self.pool = gcp('nocreate');
            if(isempty(self.pool))
                self.pool = parpool(3);
            end
            if(nargin < 2)
                self.A = num2cell(1:10);
            else
                self.A = A;
            end
            if(nargin < 3)
                self.B = num2cell(randi(10,1,10));
            else
                self.B = B;
            end
        end
        function tearDown(self)
            % Keep the parallel pool until object is dereferenced
%             delete(self.pool);
        end
        function testIdentity(self)
            parout = self.func(@self.identity,self.A);
            out = self.nonparfunc(@self.identity,self.A);
            assertEqual(parout,out);
            parout = self.func(@self.identity,self.B);
            out = self.nonparfunc(@self.identity,self.B);
            assertEqual(parout,out);
        end
        function testIdentityNotUniform(self)
            parout = self.func(@self.identity,self.A,'UniformOutput',false);
            out = self.nonparfunc(@self.identity,self.A,'UniformOutput',false);
            assertEqual(parout,out);
            parout = self.func(@self.identity,self.B,'UniformOutput',false);
            out = self.nonparfunc(@self.identity,self.B,'UniformOutput',false);
            assertEqual(parout,out);
        end
        function testSquare(self)
            parout = self.func(@self.square,self.A);
            out = self.nonparfunc(@self.square,self.A);
            assertEqual(parout,out);
            parout = self.func(@self.square,self.B);
            out = self.nonparfunc(@self.square,self.B);
            assertEqual(parout,out);
        end
        function twoInputs(self)
            parout = self.func(@times,self.A,self.B);
            out = self.nonparfunc(@times,self.A,self.B);
            assertEqual(parout,out);
        end
        function testErrors(self)
            errorCaught = false;
            try
                parout = self.func(@self.badFunction,self.A);
            catch
                errorCaught = true;
            end
            assert(errorCaught);
            errorCaught = false;
            try
                parout = self.func(@self.badFunction,self.A,'ErrorHandler',@(varargin) NaN);
            catch err
                errorCaught = true;
            end
            assert(~errorCaught);
            assertEqual(parout,NaN(size(self.A)));
        end
        % function testSpeed(self)
        %     tic
        %         parout = self.func(@self.slowFunction,self.A);
        %     parTime = toc;
        %     tic
        %         out = self.nonparfunc(@self.slowFunction,self.A);
        %     time = toc;
        %     assert(parTime < time);
        %     assertEqual(parout,out);
        % end
        function headingActual(self)
            self.func(@self.identity,self.A,'Heading','Hello world: ');
        end
        function testHeading(self)
            out = evalc('self.headingActual');
        end
        function testReturnFutures(self)
            F = self.func(@self.identity,self.A,'ReturnFutures',true);
            assert(isa(F,'parallel.Future'));
        end
        function testNoOutput(self)
            self.func(@disp,self.A);
            self.func(@self.identity,self.A,'NumOutputs',0);
        end
        function displayDiariesActual(self)
            self.func(@disp,self.A,'DisplayDiaries',true);
        end
        function testDisplayDiaries(self)
            out = evalc('self.displayDiariesActual');
        end
        function testUseErrorStruct(self)
            % The default backwards compatible behavior with cellfun is to use an
            % old-style Exception structure
            out = self.func(@self.badFunction,self.A, ...
                'UseErrorStruct',true, ...
                'ErrorHandler',@(varargin) isa(varargin{1},'MException'));
            assertEqual(out,false(size(self.A)));
            % This function allows you to use the new-style MException
            % object if you want to turn it on. Plus you get access to the
            % data structure
            out = self.func(@self.badFunction,self.A, ...
                'UseErrorStruct',false, ...
                'ErrorHandler',@(varargin) isa(varargin{1},'MException'));
            assertEqual(out,true(size(self.A)));
        end
        function testUpdateInterval(self)
            self.func(@self.identity,self.B,'UpdateInterval',0);
            self.func(@self.identity,self.B,'UpdateInterval',0.1);
            self.func(@self.identity,self.B,'UpdateInterval',2);
        end
        function delete(self)
            delete@TestCase(self);
            delete(self.pool);
        end
    end
    methods (Static)
        function x = identity(x)
        end
        function x2 = square(x)
            x2 = x*x;
        end
        function x = badFunction(x)
            assert(false);
        end
        function x = slowFunction(x)
            pause(0.1);
        end
        function x = randFunction(x)
            pause(randi(3));
        end
    end
end