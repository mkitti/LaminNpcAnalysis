function setPoolSize(poolSize,clusterProfile)
%SETPOOLSIZE sets parallel pool (matlabpool) to specified size irrespective of current status
%
% setPoolSize
% setPoolSize(poolSize)
% setPoolSize(poolSize,clusterProfile)
% setPoolSize([],clusterProfile)
%
% Input: poolSize - the parallel pool (matlabpool) size (number of
% workers). If not specified / empty then the default size of the cluster
% profile is used.
%
% clusterProfile - a char describing a parallel cluster profile or
% a parallel.Cluster object. If not specified / empty then the current
% parallel cluster profile is used. If there is no current parallel cluster
% profile, then parallel.defaultClusterProfile is used.
% 
%
% Hunter Elliott
% 12/2015
% Mark Kittispikul - Added clusterProfile, default size from cluster
% 10/2016

if nargin < 1
    poolSize = [];
end

%Get current poolsize
poolobj = gcp('nocreate'); %Just check the current size
if isempty(poolobj)
    currSize = 0;
    currProfile = '';
    if nargin < 2
        % Use the default cluster profile is no pool exists
        clusterProfile =  parallel.defaultClusterProfile;
    end
else
    currSize = poolobj.NumWorkers;
    currProfile = poolobj.Cluster.Profile;
    if nargin < 2
        % If a pool exists, use the same cluster
        clusterProfile = poolobj.Cluster;
    end
end

if(ischar(clusterProfile))
    % Convert profile name to a parallel.Cluster object
    cluster = parcluster(clusterProfile);
elseif(isa(clusterProfile,'parallel.Cluster'))
    % We already have a cluster, get a cluster profile name
    cluster = clusterProfile;
    clusterProfile = cluster.Profile;
end

if isempty(poolSize)
    % Get default pool size from the cluster
    poolSize = cluster.NumWorkers;
end

if isempty(poolSize)
    %Just in case the cluster profile does not define a poolSize,
    %Either do nothing if there is a current parallel pool
    %or start a pool on on cluster if there is no current parallel pool
    
    if(isempty(poolobj))
        % If poolobj is empty, then there is no current pool.
        parpool(cluster);
    end
elseif currSize ~= poolSize || ~strcmp(currProfile,clusterProfile)
    
    %Delete the current pool (Doesn't seem to be possible to just
    %add/remove...)
    delete(poolobj)
        
    if poolSize > 0
        parpool(cluster,poolSize);
    end    
end
