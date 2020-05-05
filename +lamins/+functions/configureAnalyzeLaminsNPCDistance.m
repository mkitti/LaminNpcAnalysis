function [ D, rD ] = configureAnalyzeLaminsNPCDistance( MD, lamin_z_position, npc_z_position, lamin_channel, npc_channel )
%analyzeLaminsNPCDistance Analyze distance between lamin meshwork

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
if(nargin < 1 || isempty(MD))
    MD = MovieData.load;
elseif(ischar(MD))
    MD = MovieData.load(MD);
end

outputDir = 'analyzeLaminsNPCDistance_2018_05_09';

cd(MD.movieDataPath_);
mkdir(outputDir);
cd(outputDir);

if(nargin < 3)
    if(exist('z_parameters.mat','file'))
        load('z_parameters.mat');
        lamin_z_position
        npc_z_position
        if(exist('lamin_channel','var'))
            lamin_channel
            npc_channel
        end
        if(exist('cropRect','var'))
            cropRect
        end
    else
        if(regexp(MD.channels_(1).name_,'SIM561','once') || regexp(MD.channels_(1).name_,'SIM488','once'))
            lamin_channel = 2;
            npc_channel = 1;
        else
            lamin_channel = 1;
            npc_channel = 2;
        end
        [~,~,Zindices] = autofocus(MD,[MD.imSize_/2-64 128 128],'WAVS');
        Zindices(cellfun('isempty',Zindices)) = { round(MD.zSize_/2) };
        Zindices = cellfun(@min,Zindices);
        hmv = movieViewer(MD);
%         defaultLaminPos = round(MD.zSize_/2);
%         defaultNPCPos = defaultLaminPos-2;
        defaultLaminPos = Zindices(1);
        defaultNPCPos = Zindices(2);
        
        h_edit_depth=  findtag(hmv,'edit_depth');
        h_edit_depth.String = num2str(defaultLaminPos);
        h_edit_depth.Callback(h_edit_depth,[]);
        
        zpos = inputdlg({'Lamin Z Position','NPC Z Position','Lamin channel','NPC channel'}, ...
            'Enter Z Positions for Lamins and NPCS', ...
            1, ...
            {num2str(defaultLaminPos),num2str(defaultNPCPos),num2str(lamin_channel),num2str(npc_channel)}, ...
            struct('WindowStyle','normal'));
        lamin_z_position = str2double(zpos{1});
        npc_z_position = str2double(zpos{2});
        lamin_channel = str2double(zpos{3});
        npc_channel = str2double(zpos{4});
        close(hmv);
    end
end

if(~exist('lamin_channel','var'))
    lamin_channel = 1;
end
if(~exist('npc_channel','var'))
    npc_channel = 2;
end



slash_location = strfind(MD.movieDataPath_,'\');
md_title = MD.movieDataPath_(slash_location(end-1):end);

% Lamin image
I = MD.channels_(lamin_channel).loadImage(1,lamin_z_position);
I_npc = MD.channels_(npc_channel).loadImage(1,npc_z_position);

if(size(I,1) > 1024)
    if(~exist('cropRect','var'))
        hfigcrop = figure;
        imshowpair(I,I_npc);
        I_sz = size(I);
        I_center = ceil(I_sz/2);
        hrect = imrect(hfigcrop.Children(1),[I_center-[512 512] 1023 1023]);
        setResizable(hrect,false);
        cropRect = wait(hrect);
        close(hfigcrop);
    end
    I = imcrop(I,cropRect);
    I_npc = imcrop(I_npc,cropRect);
else
    cropRect = [1 1 size(I)];
end



save('z_parameters.mat','lamin_z_position','npc_z_position','lamin_channel','npc_channel','cropRect');

end