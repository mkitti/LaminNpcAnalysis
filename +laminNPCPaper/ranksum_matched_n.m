function [ p_values ] = ranksum_matched_n( A,B,subsamples)
%ranksum_matched_n Compare statistics using ranksum with matched numbers
%for each distribution, bootstrapping the the larger distribution

if(nargin < 3)
    subsamples = 100;
end

if(length(A) > length(B))
    more_n_dist = A;
    less_n_dist = B;
else
    more_n_dist = B;
    less_n_dist = A;
end

p_values = zeros(1,subsamples);

for i=1:subsamples
    perm = randperm(length(more_n_dist),length(less_n_dist));
    p_values(i) = ranksum(less_n_dist, more_n_dist(perm));
end


end

