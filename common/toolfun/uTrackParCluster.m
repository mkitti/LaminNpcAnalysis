function cluster =  uTrackParCluster(cluster)
%uTrackParCluster Set or Query the parallel.Cluster that uTrack should use
%for launching jobs via batch or createJob.
%
% Parallel pools may still use the default (local?) cluster set by matlab
%
% See also parcluster
%
% Mark Kittisopikul, January 2016
    persistent currentCluster;
    if(nargin < 1)
%         if(isempty(currentCluster))
%             % if cluster has not been set, use the default cluster
%             currentCluster = parcluster;
%         end
    else
        if(ischar(cluster))
            % attempt to convert a string profile name to a parallel
            % cluster
            cluster = parcluster(cluster);
        end
        assert(isempty(cluster) || isa(cluster,'parallel.Cluster'), ...
            'uTrackParCluster:Argument must be a parallel.Cluster, a char, or empty');
        currentCluster = cluster;
    end
    % return the current cluster stored here
    cluster = currentCluster;
end