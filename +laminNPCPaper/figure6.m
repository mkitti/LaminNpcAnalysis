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

% datafields = {'wt',        'wtr', ...
%               'scrambled', 'scrambledr', ...
%               'tprkd',     'tprkdr', ...
%               'elyskd',    'elyskdr', ...
%               'nup153kd',  'nup153kdr'};
%           
% %% Copy in WT data
%           
% LA.wt = wtLA.D*MD.pixelSize_;
% LA.wtr = wtLA.rD*MD.pixelSize_;
% 
% LB1.wt = wtLB1.D*MD.pixelSize_;
% LB1.wtr = wtLB1.rD*MD.pixelSize_;
% 
% LC.wt = wtLC.D*MD.pixelSize_;
% LC.wtr = wtLC.rD*MD.pixelSize_;
% 
% LB2.wt = wtLB2.D*MD.pixelSize_;
% LB2.wtr = wtLB2.rD*MD.pixelSize_;
% 

%% Setup

% datafields = {'scrambled', 'scrambledr', ...
%               'tprkd',     'tprkdr', ...
%               'elyskd',    'elyskdr', ...
%               'nup153kd',  'nup153kdr'};


datafields = {'scrambled', 'scrambledr', ...
              'tprkd',     'tprkdr', ...
              'nup153kd',  'nup153kdr', ...
              'elyskd',    'elyskdr' };

if isfield(LA,'wt')
    LA = rmfield(LA,{'wt','wtr'});
    LB1 = rmfield(LB1,{'wt','wtr'});
    LB2 = rmfield(LB2,{'wt','wtr'});
    LC = rmfield(LC,{'wt','wtr'});
end

%% Copy face data from wt
% LAface.wt = wtLA.fD*MD.pixelSize_;
% LAface.wtr = wtLA.frD*MD.pixelSize_;
% 
% LB1face.wt = wtLB1.fD*MD.pixelSize_;
% LB1face.wtr = wtLB1.frD*MD.pixelSize_;
% 
% LB2face.wt = wtLB2.fD*MD.pixelSize_;
% LB2face.wtr = wtLB2.frD*MD.pixelSize_;
% 
% LCface.wt = wtLC.fD*MD.pixelSize_;
% LCface.wtr = wtLC.frD*MD.pixelSize_;

if isfield(LAface,'wt')
    LAface = rmfield(LAface,{'wt','wtr'});
    LB1face = rmfield(LB1face,{'wt','wtr'});
    LB2face = rmfield(LB2face,{'wt','wtr'});
    LCface = rmfield(LCface,{'wt','wtr'});
end


%% Order fields so WT is first

LA = orderfields(LA,datafields);
LB1 = orderfields(LB1,datafields);
LB2 = orderfields(LB2,datafields);
LC = orderfields(LC,datafields);

%% Order fields so wt is first
LAface = orderfields(LAface,datafields);
LB1face = orderfields(LB1face,datafields);
LB2face = orderfields(LB2face,datafields);
LCface = orderfields(LCface,datafields);

%% Plot violin plots for LA-NPC
hfig_LA = figure;
hfig_LA.Position(3:4) = 650;
hfig_LA.Renderer='Painters';
ax = subplot(2,2,1);
htitle = title('B','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LA,false);
% ylim([0 250]);
ylim([0 250]);
view(90,90);
ylabel('NPC - LA Fiber Distance (nm)');
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
% title('LA');
% saveas(gcf,'fig6_LA_dist.fig');
% saveas(gcf,'fig6_LA_dist.pdf');

%% LA Diff plot
ax = subplot(2,2,3);
htitle = title('C','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h,30);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LA');
% saveas(gcf,'fig6_LA_diff.fig');
% saveas(gcf,'fig6_LA_diff.pdf');

%% Calculate median and p-values
if(isfield(fig6,'LA'))
    % [fig6.LA.median, fig6.LA.median_diff, fig6.LA.p_values, fig6.LA.p_values_matched, fig6.LA.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LA);
    [fig6.LA] = laminNPCPaper.calc_median_and_p_values(LA);
    % [fig6.LA.vs_scrambled.median, fig6.LA.vs_scrambled.median_diff, fig6.LA.vs_scrambled.p_values, fig6.LA.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LA);
    [fig6.LA.vs_scrambled] = laminNPCPaper.compareWithScrambled(LA);
end

%% Plot violin plots for LA face-NPC
% figure;
subplot(2,2,2);
htitle = title('D','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LAface,false);
ylim([0 350]);
ylabel('NPC - LA Face Center Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LA');
% saveas(gcf,'fig6_LA_face_dist.fig');
% saveas(gcf,'fig6_LA_face_dist.pdf');

%% Diff plot
subplot(2,2,4);
htitle = title('E','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LA');
% saveas(gcf,'fig6_LA_face_diff.fig');
% saveas(gcf,'fig6_LA_face_diff.pdf');

%% Save plot
saveas(hfig_LA,'fig6_LA.fig');
saveas(hfig_LA,'fig6_LA.pdf');

%% Save smaller plot
hfig_LA.Position(3:4) = 400;
median_scatters = findall(hfig_LA,'type','Scatter','Marker','o');
[median_scatters.SizeData] = deal(12);
saveas(hfig_LA,'fig6_LA_400.fig');
saveas(hfig_LA,'fig6_LA_400.pdf');

%% Calculate median and p-values
if(isfield(fig6,'LAface'))
    % [fig6.LAface.median, fig6.LAface.median_diff, fig6.LAface.p_values, fig6.LAface.p_values_matched, fig6.LAface.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LAface);
    [fig6.LAface] = laminNPCPaper.calc_median_and_p_values(LAface);
    % [fig6.LAface.vs_scrambled.median, fig6.LAface.vs_scrambled.median_diff, fig6.LAface.vs_scrambled.p_values, fig6.LAface.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LAface);
    [fig6.LAface.vs_scrambled] = laminNPCPaper.compareWithScrambled(LAface);
end




%% Plot violin plots for LB1-NPC
hfig_LB1 = figure;
hfig_LB1.Renderer='Painters';
hfig_LB1.Position(3:4) = 650;
ax = subplot(2,2,1);
htitle = title('B','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LB1,false);
% ylim([0 250]);
ylim([0 250]);
view(90,90);
ylabel('NPC - LB1 Fiber Distance (nm)');
% ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
% xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB1');
% saveas(gcf,'fig6_LB1_dist.fig');
% saveas(gcf,'fig6_LB1_dist.pdf');

%% LB1 Diff plot
ax = subplot(2,2,3);
htitle = title('C','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h,30);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
% xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB1');
% saveas(gcf,'fig6_LB1_diff.fig');
% saveas(gcf,'fig6_LB1_diff.pdf');

%% Calculate median and p-values
if(isfield(fig6,'LB1'))
    % [fig6.LB1.median, fig6.LB1.median_diff, fig6.LB1.p_values, fig6.LB1.p_values_matched, fig6.LB1.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LB1);
    [fig6.LB1] = laminNPCPaper.calc_median_and_p_values(LB1);
    % [fig6.LB1.vs_scrambled.median, fig6.LB1.vs_scrambled.median_diff, fig6.LB1.vs_scrambled.p_values, fig6.LB1.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LB1);
    [fig6.LB1.vs_scrambled] = laminNPCPaper.compareWithScrambled(LB1);
end


%% Plot violin plots for LB1 face-NPC
% figure;
ax = subplot(2,2,2);
htitle = title('D','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LB1face,false);
ylim([0 350]);
ylabel('NPC - LB1 Face Center Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB1');
% saveas(gcf,'fig6_LB1_face_dist.fig');
% saveas(gcf,'fig6_LB1_face_dist.pdf');

%% Diff plot
ax = subplot(2,2,4);
htitle = title('E','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB1');
% saveas(gcf,'fig6_LB1_face_diff.fig');
% saveas(gcf,'fig6_LB1_face_diff.pdf');

%% Save plot
saveas(hfig_LB1,'fig6_LB1.fig');
saveas(hfig_LB1,'fig6_LB1.pdf');

%% Save smaller plot
hfig_LB1.Position(3:4) = 400;
median_scatters = findall(hfig_LB1,'type','Scatter','Marker','o');
[median_scatters.SizeData] = deal(12);
saveas(hfig_LB1,'fig6_LB1_400.fig');
saveas(hfig_LB1,'fig6_LB1_400.pdf');

%% Calculate median and p-values
if(isfield(fig6,'LB1face'))
    % [fig6.LB1face.median, fig6.LB1face.median_diff, fig6.LB1face.p_values, fig6.LB1face.p_values_matched, fig6.LB1face.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LB1face);
    [fig6.LB1face] = laminNPCPaper.calc_median_and_p_values(LB1face);
    % [fig6.LB1face.vs_scrambled.median, fig6.LB1face.vs_scrambled.median_diff, fig6.LB1face.vs_scrambled.p_values, fig6.LB1face.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LB1face);
    [fig6.LB1face.vs_scrambled] = laminNPCPaper.compareWithScrambled(LB1face);
end






%% Plot violin plots for LB2-NPC
hfig_LB2 = figure;
hfig_LB2.Position(3:4) = 650;
hfig_LB2.Renderer='Painters';
ax = subplot(2,2,1);
htitle = title('B','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LB2,false);
% ylim([0 250]);
ylim([0 250]);
view(90,90);
ylabel('NPC - LB2 Lamin Fiber Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
% xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB2');
% saveas(gcf,'fig6_LB2_dist.fig');
% saveas(gcf,'fig6_LB2_dist.pdf');

%% LB2 Diff plot
ax = subplot(2,2,3);
htitle = title('C','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h,30);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
% xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB2');
% saveas(gcf,'fig6_LB2_diff.fig');
% saveas(gcf,'fig6_LB2_diff.pdf');


%% Calculate median and p-values
if(isfield(fig6,'LB2'))
    % [fig6.LB2.median, fig6.LB2.median_diff, fig6.LB2.p_values, fig6.LB2.p_values_matched, fig6.LB2.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LB2);
    [fig6.LB2] = laminNPCPaper.calc_median_and_p_values(LB2);
    % [fig6.LB2.vs_scrambled.median, fig6.LB2.vs_scrambled.median_diff, fig6.LB2.vs_scrambled.p_values, fig6.LB2.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LB2);
    [fig6.LB2.vs_scrambled] = laminNPCPaper.compareWithScrambled(LB2);
end

%% Plot violin plots for LB2 face-NPC
% figure;
ax = subplot(2,2,2);
htitle = title('D','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LB2face,false);
ylim([0 350]);
ylabel('NPC - LB2 Face Center Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB2');
% saveas(gcf,'fig6_LB2_face_dist.fig');
% saveas(gcf,'fig6_LB2_face_dist.pdf');

%% Diff plot
ax = subplot(2,2,4);
htitle = title('E','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LB2');
% saveas(gcf,'fig6_LB2_face_diff.fig');
% saveas(gcf,'fig6_LB2_face_diff.pdf');

%% Save plot
saveas(hfig_LB2,'fig6_LB2.fig');
saveas(hfig_LB2,'fig6_LB2.pdf');

%% Save smaller plot
hfig_LB2.Position(3:4) = 400;
median_scatters = findall(hfig_LB2,'type','Scatter','Marker','o');
[median_scatters.SizeData] = deal(12);
saveas(hfig_LB2,'fig6_LB2_400.fig');
saveas(hfig_LB2,'fig6_LB2_400.pdf');

%% Calculate median and p-values
if(isfield(fig6,'LB2face'))
    % [fig6.LB2face.median, fig6.LB2face.median_diff, fig6.LB2face.p_values, fig6.LB2face.p_values_matched, fig6.LB2face.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LB2face);
    [fig6.LB2face] = laminNPCPaper.calc_median_and_p_values(LB2face);
    % [fig6.LB2face.vs_scrambled.median, fig6.LB2face.vs_scrambled.median_diff, fig6.LB2face.vs_scrambled.p_values, fig6.LB2face.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LB2face);
    [fig6.LB2face.vs_scrambled] = laminNPCPaper.compareWithScrambled(LB2face);
end


%% Plot violin plots for LC-NPC
hfig_LC = figure;
hfig_LC.Position(3:4) = 650;
hfig_LC.Renderer='Painters';
ax = subplot(2,2,1);
htitle = title('B','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LC,false);
% ylim([0 250]);
ylim([0 250]);
view(90,90);
ylabel('NPC - LC Fiber Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
% xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LC');
% saveas(gcf,'fig6_LC_dist.fig');
% saveas(gcf,'fig6_LC_dist.pdf');

%% LC Diff plot
ax = subplot(2,2,3);
htitle = title('C','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h,30);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
% xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LC');
% saveas(gcf,'fig6_LC_diff.fig');
% saveas(gcf,'fig6_LC_diff.pdf');

%% Calculate median and p-values
if(isfield(fig6,'LC'))
    % [fig6.LC.median, fig6.LC.median_diff, fig6.LC.p_values, fig6.LC.p_values_matched, fig6.LC.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LC);
    [fig6.LC] = laminNPCPaper.calc_median_and_p_values(LC);
    % [fig6.LC.vs_scrambled.median, fig6.LC.vs_scrambled.median_diff, fig6.LC.vs_scrambled.p_values, fig6.LC.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LC);
    [fig6.LC.vs_scrambled] = laminNPCPaper.compareWithScrambled(LC);
end

%% Plot violin plots for LC face-NPC
% figure;
ax = subplot(2,2,2);
htitle = title('D','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
h = lamins.functions.plot_positive_violin_pairs(LCface,false);
ylim([0 350]);
ylabel('NPC - LC Face Center Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LC');
% saveas(gcf,'fig6_LC_face_dist.fig');
% saveas(gcf,'fig6_LC_face_dist.pdf');

%% Diff plot
ax = subplot(2,2,4);
htitle = title('E','Units','normalized');
htitle.Position(1:2) = [-0.1 1.05];
hdiff = lamins.functions.plot_violin_diff(h);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);
xticklabels({'Scrambled','TPR KD','NUP153 KD','ELYS KD'});
% title('LC');
% saveas(gcf,'fig6_LC_face_diff.fig');
% saveas(gcf,'fig6_LC_face_diff.pdf');

%% Save plot
saveas(hfig_LC,'fig6_LC.fig');
saveas(hfig_LC,'fig6_LC.pdf');

%% Save smaller plot
median_scatters = findall(hfig_LC,'type','Scatter','Marker','o');
[median_scatters.SizeData] = deal(12);
hfig_LC.Position(3:4) = 400;
saveas(hfig_LC,'fig6_LC_400.fig');
saveas(hfig_LC,'fig6_LC_400.pdf');


%% Calculate median and p-values
if(isfield(fig6,'LCface'))
    % [fig6.LCface.median, fig6.LCface.median_diff, fig6.LCface.p_values, fig6.LCface.p_values_matched, fig6.LCface.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(LCface);
    [fig6.LCface] = laminNPCPaper.calc_median_and_p_values(LCface);
    % [fig6.LCface.vs_scrambled.median, fig6.LCface.vs_scrambled.median_diff, fig6.LCface.vs_scrambled.p_values, fig6.LCface.vs_scrambled.p_values_matched] = laminNPCPaper.compareWithScrambled(LCface);
    [fig6.LCface.vs_scrambled] = laminNPCPaper.compareWithScrambled(LCface);
end


%% Plot Histograms for LA
[ hfig, hfig2, hfig3 ] = lamins.functions.plot_histogram_2d(LA.elyskd,LA.elyskdr,LAface.elyskd,LAface.elyskdr,1);

%% Modify added values
if isfield(LAadd,'wt')
    LAadd = rmfield(LAadd,{'wt','wtr'});
    LB1add = rmfield(LB1add,{'wt','wtr'});
    LB2add = rmfield(LB2add,{'wt','wtr'});
    LCadd = rmfield(LCadd,{'wt','wtr'});
end

%% Added for face size
fig6.LAadd = laminNPCPaper.calc_median_and_p_values(LAadd);
[fig6.LAadd.vs_scrambled] = laminNPCPaper.compareWithScrambled(LAadd);
fig6.LB1add = laminNPCPaper.calc_median_and_p_values(LB1add);
[fig6.LB1add.vs_scrambled] = laminNPCPaper.compareWithScrambled(LB1add);
fig6.LB2add = laminNPCPaper.calc_median_and_p_values(LB2add);
[fig6.LB2add.vs_scrambled] = laminNPCPaper.compareWithScrambled(LB2add);
fig6.LCadd = laminNPCPaper.calc_median_and_p_values(LCadd);
[fig6.LCadd.vs_scrambled] = laminNPCPaper.compareWithScrambled(LCadd);
% writetable([laminNPCPaper.distanceStructToTable(fig6.LAadd,'LAadd'); laminNPCPaper.distanceStructToTable(fig6.LB1add,'LB1add'); laminNPCPaper.distanceStructToTable(fig6.LB2add,'LB2add'); laminNPCPaper.distanceStructToTable(fig6.LCadd,'LCadd')],'2019_12_24_added_npc.xlsx','WriteRowNames',true);