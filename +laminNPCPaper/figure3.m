%% Setup
pixelSize = MD.pixelSize_;

%% Build lamin data
fig3_lamin.wtLA = wtLA.D*pixelSize;
fig3_lamin.wtLAr = wtLA.rD*pixelSize;
fig3_lamin.wtLC = wtLC.D*pixelSize;
fig3_lamin.wtLCr = wtLC.rD*pixelSize;
fig3_lamin.wtLB1 = wtLB1.D*pixelSize;
fig3_lamin.wtLB1r = wtLB1.rD*pixelSize;
fig3_lamin.wtLB2 = wtLB2.D*pixelSize;
fig3_lamin.wtLB2r = wtLB2.rD*pixelSize;
fig3_lamin.LB1koLA = LB1koLA.D*pixelSize;
fig3_lamin.LB1koLAr = LB1koLA.rD*pixelSize;
fig3_lamin.LACkoLB1 = LACkoLB1.D*pixelSize;
fig3_lamin.LACkoLB1r = LACkoLB1.rD*pixelSize;

%% Build face data
fig3_face.wtLA = wtLA.fD*pixelSize;
fig3_face.wtLAr = wtLA.frD*pixelSize;
fig3_face.wtLC = wtLC.fD*pixelSize;
fig3_face.wtLCr = wtLC.frD*pixelSize;
fig3_face.wtLB1 = wtLB1.fD*pixelSize;
fig3_face.wtLB1r = wtLB1.frD*pixelSize;
fig3_face.wtLB2 = wtLB2.fD*pixelSize;
fig3_face.wtLB2r = wtLB2.frD*pixelSize;
fig3_face.LB1koLA = LB1koLA.fD*pixelSize;
fig3_face.LB1koLAr = LB1koLA.frD*pixelSize;
fig3_face.LACkoLB1 = LACkoLB1.fD*pixelSize;
fig3_face.LACkoLB1r = LACkoLB1.frD*pixelSize;

%% Setup subplots
hfig = figure;
hfig.Position(1:2) = hfig.Position(1:2) - (700-hfig.Position(3:4));
hfig.Position(3:4) = 700;
labelStyle = {};


%% Plot violin plots for lamin-NPC
% figure;
ax = subplot(2,2,1);
htitle = title('A','Units','normalized');
% htitle.Position(1) = ax.OuterPosition(1)-0.1;
htitle.Position(1:2) = [-0.1 1.1];
% annotation('textbox',[ax.OuterPosition(1:2)+[0 ax.OuterPosition(4)-0.1] 0.1 0.1],'String','A',labelStyle{:})
h = lamins.functions.plot_positive_violin_pairs(fig3_lamin,false);
% ylim([0 250]);
ylim([0 160]);
view(90,90);
ylabel('NPC - Lamin Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';

%% Diff plot
ax = subplot(2,2,3);
htitle = title('B','Units','normalized');
htitle.Position(1:2) = [-0.1 1.1];
% htitle.Position(1) = ax.OuterPosition(1)-0.1;
% annotation('textbox',[ax.OuterPosition(1:2)+[0 ax.OuterPosition(4)-0.1] 0.1 0.1],'String','B',labelStyle{:})
hdiff = lamins.functions.plot_violin_diff(h);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';

%% Calculate median and p-values
% [fig3.lamin.median, fig3.lamin.median_diff, fig3.lamin.p_values, fig3.lamin.p_values_matched, fig3.lamin.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(fig3_lamin);
[fig3.lamin] = laminNPCPaper.calc_median_and_p_values(fig3_lamin);

% %% Calculate p-values
% fields = fieldnames(fig3_lamin);
% for f = 1:2:length(fields)
%     combined_field = [fields{f} '_vs_' fields{f+1}];
%     fig3_lamin_p_values.(combined_field) =  ranksum(fig3_lamin.(fields{f}),fig3_lamin.(fields{f+1}) );
% end
% 
% %% Calculate p-values matched
% fields = fieldnames(fig3_lamin);
% for f = 1:2:length(fields)
%     combined_field = [fields{f} '_vs_' fields{f+1}];
%     fig3_lamin_p_values_matched.(combined_field) =  mean(laminNPCPaper.ranksum_matched_n(fig3_lamin.(fields{f}),fig3_lamin.(fields{f+1}) ));
% end
% 
% %% Calculate median
% fields = fieldnames(fig3_lamin);
% for f = 1:2:length(fields)
%     combined_field = [fields{f} '_minus_' fields{f+1}];
%     fig3_lamin_median.(fields{f}) = median(fig3_lamin.(fields{f}));
%     fig3_lamin_median.(fields{f+1}) = median(fig3_lamin.(fields{f+1}));
%     fig3_lamin_median_diff.(combined_field) =  fig3_lamin_median.(fields{f})-fig3_lamin_median.(fields{f+1});
% end


%% Plot violin plots for face-NPC
% figure;
ax = subplot(2,2,2);
htitle = title('C','Units','normalized');
htitle.Position(1:2) = [-0.1 1.1];
% htitle.Position(1) = ax.OuterPosition(1)-0.1;
% annotation('textbox',[ax.OuterPosition(1:2)+[0 ax.OuterPosition(4)-0.1] 0.1 0.1],'String','C',labelStyle{:})
h = lamins.functions.plot_positive_violin_pairs(fig3_face,false);
ylim([0 350]);
ylabel('NPC - Face Center Distance (nm)');
ax = h(1).ScatterPlot.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);

%% Diff plot
ax = subplot(2,2,4);
htitle = title('D','Units','normalized');
htitle.Position(1:2) = [-0.1 1.1];
% htitle.Position(1) = ax.OuterPosition(1)-0.1;
% annotation('textbox',[ax.OuterPosition(1:2)+[0 ax.OuterPosition(4)-0.1] 0.1 0.1],'String','D',labelStyle{:})
hdiff = lamins.functions.plot_violin_diff(h);
ax = hdiff(1).positive.Parent;
ax.XMinorGrid = 'on';
xtickangle(45);

%% Calculate median and p-values
% [fig3.face.median, fig3.face.median_diff, fig3.face.p_values, fig3.face.p_values_matched, fig3.face.p_values_dispersion] = laminNPCPaper.calc_median_and_p_values(fig3_face);
[fig3.face] = laminNPCPaper.calc_median_and_p_values(fig3_face);


% %% Calculate p-values
% fields = fieldnames(fig3_face);
% for f = 1:2:length(fields)
%     combined_field = [fields{f} '_vs_' fields{f+1}];
%     fig3_face_p_values.(combined_field) =  ranksum(fig3_face.(fields{f}),fig3_face.(fields{f+1}));
% end
% 
% %% Calculate p-values matched
% fields = fieldnames(fig3_face);
% for f = 1:2:length(fields)
%     combined_field = [fields{f} '_vs_' fields{f+1}];
%     fig3_face_p_values_matched.(combined_field) =  mean(laminNPCPaper.ranksum_matched_n(fig3_face.(fields{f}),fig3_face.(fields{f+1}) ));
% end
% 
% %% Calculate median
% fields = fieldnames(fig3_face);
% for f = 1:2:length(fields)
%     combined_field = [fields{f} '_minus_' fields{f+1}];
%     fig3_face_median.(fields{f}) = median(fig3_face.(fields{f}));
%     fig3_face_median.(fields{f+1}) = median(fig3_face.(fields{f+1}));
%     fig3_face_median_diff.(combined_field) =  fig3_face_median.(fields{f})-fig3_face_median.(fields{f+1});
% end

%% Test

hfig.Renderer='Painters';
saveas(gcf,'fig3_wt_and_kos.fig');
saveas(gcf,'fig3_wt_and_kos.pdf');
