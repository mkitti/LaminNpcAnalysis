%% Setup

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

datafields = {'wt',        'wtr', ...
              'scrambled', 'scrambledr', ...
              'tprkd',     'tprkdr', ...
              'elyskd',    'elyskdr', ...
              'nup153kd',  'nup153kdr'};

%% Add and subtract

clear LAadd LAsub LB1add LB1sub LB2add LB2sub LCadd LCsub
          
for i=1:length(datafields)
    LAadd.(datafields{i})  = LA.(datafields{i})  + LAface.(datafields{i});
    LAsub.(datafields{i})  = LA.(datafields{i})  - LAface.(datafields{i});
    LB1add.(datafields{i}) = LB1.(datafields{i}) + LB1face.(datafields{i});
    LB1sub.(datafields{i}) = LB1.(datafields{i}) - LB1face.(datafields{i});
    LB2add.(datafields{i}) = LB2.(datafields{i}) + LB2face.(datafields{i});
    LB2sub.(datafields{i}) = LB2.(datafields{i}) - LB2face.(datafields{i});
    LCadd.(datafields{i})  = LC.(datafields{i})  + LCface.(datafields{i});
    LCsub.(datafields{i})  = LC.(datafields{i})  - LCface.(datafields{i});
end

%% Plot violin plots for LA-NPC
figure; h = lamins.functions.plot_positive_violin_pairs(LAadd,false);
% ylim([0 250]);
ylim([0 400]);
view(90,90);
ylabel('NPC - Lamin + Face Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
title('LA');

%% LA Diff plot
hdiff = lamins.functions.plot_violin_diff(h,50);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
title('LA');

%% Plot violin plots for LB1-NPC
figure; h = lamins.functions.plot_positive_violin_pairs(LB1add,false);
% ylim([0 250]);
ylim([0 400]);
view(90,90);
ylabel('NPC - Lamin + Face Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
title('LB1');

%% LB1 Diff plot
hdiff = lamins.functions.plot_violin_diff(h,50);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
title('LB1');

%% Plot violin plots for LB2-NPC
figure; h = lamins.functions.plot_positive_violin_pairs(LB2add,false);
% ylim([0 250]);
ylim([0 400]);
view(90,90);
ylabel('NPC - Lamin + Face Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
title('LB2');

%% LB2 Diff plot
hdiff = lamins.functions.plot_violin_diff(h,50);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
title('LB2');

%% Plot violin plots for LC-NPC
figure; h = lamins.functions.plot_positive_violin_pairs(LCadd,false);
% ylim([0 250]);
ylim([0 400]);
view(90,90);
ylabel('NPC - Lamin + Face Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
title('LC');

%% LA Diff plot
hdiff = lamins.functions.plot_violin_diff(h,50);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
title('LC');