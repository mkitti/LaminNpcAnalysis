function [ p_values ] = ranksum_matched_n( A,B,subsamples)
%ranksum_matched_n Compare statistics using ranksum with matched numbers
%for each distribution, bootstrapping the the larger distribution

%     laminNPCAnalysis - Analyze Lamin Fibers and Nuclear Pore Complexes
%     Copyright (C) 2020 Mark Kittisopikul, Northwestern University
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

