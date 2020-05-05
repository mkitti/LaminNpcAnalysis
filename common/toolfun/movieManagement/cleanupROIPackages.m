function cleanupROIPackages(MD, packageName, varargin)
%CLEANUPROIPACKAGES cleans packages in ROIs and optionally recreate new packages
%
%    cleanupROIPackages(MD, packageName) processes each ROIs from the
%    input movie tree and cleans a top-level package of type packageName.
%    It first finds a package of type packageName in the movie ancestor,
%    geos into each ROI and unlinks the package and all its processes from
%    the ROI if the package is shared.
%
%    cleanupROIPackages(MD, packageName, process2keep) additionally
%    preserves the processes of the top-level package of index specified by
%    process2keep from being unlinked. Additionally, it creates a new
%    package of type packageName in each ROI and links the kept process(es)
%    to each ROI package. Warning : this result in individual processes
%    being shared by multiple packages of different owners.
%
%    Examples:
%
%        cleanupROIPackages(MD, 'WindowingPackage')
%        cleanupROIPackages(MD, 'WindowingPackage', 1)
%
% Sebastien Besson, Mar 2014

% Input check
ip = inputParser();
ip.addRequired('packageName', @ischar);
ip.addOptional('process2keep', [], @isnumeric);
ip.addOptional('verbose', true, @isscalar);
ip.parse(packageName, varargin{:})

% Retrieve package of input class from ancestor
ancestor = MD.getAncestor();
packageIndex = ancestor.getPackageIndex(packageName, 1, false);
package = ancestor.getPackage(packageIndex);

% Unlink package and processes from children movies
for movie  = ancestor.getDescendants()
    cleanPackage(movie, package, ip.Results.process2keep,...
        ip.Results.verbose);
end

% Return if no process is kept
if isempty(ip.Results.process2keep), return; end

% Recreate packages and link kept process to each of them
for movie  = ancestor.getDescendants()
    recreatePackage(movie, package, ip.Results.process2keep,...
        ip.Results.verbose);
end

function cleanPackage(movie, package, process2keep, verbose)

% Compute list of processes to unlink
processes2clean = ~cellfun(@isempty, package.processes_);
processes2clean(process2keep) = false;

% Unlink processes and package
for i = find(processes2clean)
    status = movie.unlinkProcess(package.getProcess(i));
    if status && verbose,
        fprintf(1, '  Unlinked %s process\n',...
            package.getProcess(i).getName());
    end
end
status = movie.unlinkPackage(package);
if status && verbose,
    fprintf(1, '  Unlinked %s package\n', package.getName());
end

function recreatePackage(movie, package, process2keep, verbose)

% Create a new package using the default constructor
packageName =  class(package);
packageIndex = movie.getPackageIndex(packageName, 1, false);
if ~isempty(packageIndex)
    newPackage = movie.getPackage(packageIndex);
    if verbose
        fprintf(1, '  Retrieved %s package\n', newPackage.getName());
    end
else
    packageConstr = str2func(class(package));
    newPackage = packageConstr(movie);
    movie.addPackage(newPackage);
    if verbose
        fprintf(1, '  Created %s package\n', newPackage.getName());
    end
end

% Link parent processes
for i = find(process2keep)
    newPackage.setProcess(i, package.getProcess(i));
    if verbose
        fprintf(1, '  Linked %s process\n', package.getProcess(i).getName());
    end
end