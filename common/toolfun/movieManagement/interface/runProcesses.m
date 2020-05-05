function [ p ] = runProcesses( p, varargin )
%runProcesses Runs a cell array of processes

for i=1:length(p)
    fprintf('Running Process %d of %d\n',i,length(p));
    p{i}.run();
end


end

