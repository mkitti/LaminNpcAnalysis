function [ D, rD, fD, frD ] = aggregate_npc_data_from_movielist( ML )
%aggregate_npc_data_from_movielist Pull together NPC Data from movielist
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
    if(nargin < 1)
        load('movieList.mat')
        ML.sanityCheck;
    end
%     out = cellfun(@(MD) load([MD.movieDataPath_ filesep 'analyzeLaminsNPCDistance' filesep 'analyzeLaminsNPCdistance.mat']),ML.movies_,'Unif',false);
    out = cellfun(@(MD) load([MD.movieDataPath_ filesep 'analyzeLaminsNPCDistance_2018_05_09' filesep 'analyzeLaminsNPCdistance.mat']),ML.movies_,'Unif',false);
    out = [out{:}];
    D = vertcat(out.D);
    rD = vertcat(out.rD);
    fD = vertcat(out.fD);
    frD = vertcat(out.frD);
    
    if(nargout == 1)
        data.D = D;
        data.rD = rD;
        data.fD = fD;
        data.frD = frD;
        D = data;
    end


end

