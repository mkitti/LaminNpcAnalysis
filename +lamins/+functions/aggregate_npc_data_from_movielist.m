function [ D, rD, fD, frD ] = aggregate_npc_data_from_movielist( ML )
%aggregate_npc_data_from_movielist Pull together NPC Data from movielist

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

