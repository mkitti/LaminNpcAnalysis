classdef TestProgressTextMultiple < TestCase
% Test the function progressTextMultiple
    properties
    end
    methods
        function self = TestProgressTextMultiple(name)
            self@TestCase(name);
        end
        function setUp(self)
            clear progressTextMultiple;
        end
        function tearDown(self)
            clear progressTextMultiple;
        end
        function testNormalCountdown(self,pauseTime)
            if(nargin < 2)
                pauseTime = 0;
            end
            evalc('self.actualNormalCountdown(pauseTime)');
        end
        function actualNormalCountdown(self,pauseTime)
            % Test a normal progress update scenario
            if(nargin < 2)
                pauseTime = 0;
            end
            nSteps = [5 3 2];
            text = 'Normal Testing';
            o = progressTextMultiple(text,nSteps(1));
            assertEqual(o.level,1);
            assertEqual(o.iStep,0);
            assertEqual(o.nStep,nSteps(1));
            for i=1:nSteps(1)
                o = progressTextMultiple(['A' num2str(i)],nSteps(2));
                assertEqual(o.level,2);
                assertEqual(o.iStep(2),0);
                assertEqual(o.nStep(2),nSteps(2));
                for j=1:nSteps(2)
                    o = progressTextMultiple(['B' num2str(j)],nSteps(3));
                    assertEqual(o.level,3);
                    assertEqual(o.iStep(3),0);
                    assertEqual(o.nStep(3),nSteps(3));
                    for k=1:nSteps(3)
                        pause(pauseTime);
                        o = progressTextMultiple;
                        if k ~= nSteps(3)
                            assertEqual(o.iStep(3),k);
                            assertEqual(o.nStep(3),nSteps(3));
                        end
                    end
                    o = progressTextMultiple;
                    if j ~= nSteps(2)
                        assertEqual(o.iStep(2),j);
                        assertEqual(o.nStep(2),nSteps(2));
                    end
                end
                o = progressTextMultiple;
                if i ~= nSteps(1)
                    assertEqual(o.iStep(1),i);
                    assertEqual(o.nStep(1),nSteps(1));
                end
            end
        end
        function testTextChangeCountdown(self,pauseTime)
            if(nargin < 2)
                pauseTime = 0;
            end
            evalc('self.actualTextChangeCountdown(pauseTime)');
        end
        function actualTextChangeCountdown(self,pauseTime)
            % Test a progress update with changing text
            if(nargin < 2)
                pauseTime = 0;
            end
            nSteps = [3 3 4];
            text = 'Testing Text Change';
            o = progressTextMultiple(text,nSteps(1));
            assertEqual(o.level,1);
            assertEqual(o.iStep,0);
            assertEqual(o.nStep,nSteps(1));
            for i=1:nSteps(1)
                o = progressTextMultiple(['A' num2str(i)],nSteps(2));
                assertEqual(o.level,2);
                assertEqual(o.iStep(2),0);
                assertEqual(o.nStep(2),nSteps(2));
                for j=1:nSteps(2)
                    o = progressTextMultiple(['B' num2str(j)],nSteps(3));
                    assertEqual(o.level,3);
                    assertEqual(o.iStep(3),0);
                    assertEqual(o.nStep(3),nSteps(3));
                    for k=1:nSteps(3)
                        pause(pauseTime);
                        o = progressTextMultiple(['B' num2str(j) ', Thinking about ' num2str(k)]);
                        if k ~= nSteps(3)
                            assertEqual(o.iStep(3),k);
                            assertEqual(o.nStep(3),nSteps(3));
                        end
                    end
                    o = progressTextMultiple;
                    if j ~= nSteps(2)
                        assertEqual(o.iStep(2),j);
                        assertEqual(o.nStep(2),nSteps(2));
                    end
                end
                o = progressTextMultiple;
                if i ~= nSteps(1)
                    assertEqual(o.iStep(1),i);
                    assertEqual(o.nStep(1),nSteps(1));
                end
            end
        end
        function testEmptyText(self,pauseTime)
            if(nargin < 2)
                pauseTime = 0;
            end
            evalc('self.actualEmptyText(pauseTime)');
        end
        function actualEmptyText(self,pauseTime)
            % Test a progress update with empty text
            if(nargin < 2)
                pauseTime = 0;
            end
            nSteps = [2 2 2];
            text = 'Testing Empty';
            o = progressTextMultiple(text,nSteps(1));
            assertEqual(o.level,1);
            assertEqual(o.iStep,0);
            assertEqual(o.nStep,nSteps(1));
            for i=1:nSteps(1)
                % Test empty string
                o = progressTextMultiple('',nSteps(2));
                assertEqual(o.level,2);
                assertEqual(o.iStep(2),0);
                assertEqual(o.nStep(2),nSteps(2));
                for j=1:nSteps(2)
                    % Text empty matrix
                    o = progressTextMultiple([],nSteps(3));
                    assertEqual(o.level,3);
                    assertEqual(o.iStep(3),0);
                    assertEqual(o.nStep(3),nSteps(3));
                    for k=1:nSteps(3)
                        pause(pauseTime);
                        o = progressTextMultiple;
                        if k ~= nSteps(3)
                            assertEqual(o.iStep(3),k);
                            assertEqual(o.nStep(3),nSteps(3));
                        end
                    end
                    o = progressTextMultiple;
                    if j ~= nSteps(2)
                        assertEqual(o.iStep(2),j);
                        assertEqual(o.nStep(2),nSteps(2));
                    end
                end
                o = progressTextMultiple;
                if i ~= nSteps(1)
                    assertEqual(o.iStep(1),i);
                    assertEqual(o.nStep(1),nSteps(1));
                end
            end
        end
        function testOverrun(self)
            evalc('self.actualOverrun');
        end
        function actualOverrun(self)
            % Test situation where the number of steps specified is
            % exceeded
            nSteps = 5;
            overrun = 3;
            text = 'Testing Overrun';
            o = progressTextMultiple(text,nSteps(1));
            assertEqual(o.level,1);
            assertEqual(o.iStep,0);
            assertEqual(o.nStep,nSteps(1));
            lastwarn('');
            warning('off','progressTextMultiple:LevelZero');
            for i=1:(nSteps+overrun)
                o = progressTextMultiple;
            end
            % Ensure that a warning is issued the first time
            [msgstr,msgid] = lastwarn;
            assertEqual(msgid,'progressTextMultiple:LevelZero');

            lastwarn('');
            for i=1:(nSteps+overrun)
                o = progressTextMultiple;
            end
            % Ensrue that a warning is not thrown the second time
            [msgstr,msgid] = lastwarn;
            assertEqual(msgid,'');
        end
    end
end
