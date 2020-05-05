load('movieList.mat')
ML.sanityCheck
out = cellfun(@(MD) load([MD.movieDataPath_ filesep 'analyzeLaminsNPCDistance_2018_05_09' filesep 'analyzeLaminsNPCdistance.mat']),ML.movies_,'Unif',false)
out = [out{:}];
rD = vertcat(out.rD);
D = vertcat(out.D);
fD = vertcat(out.fD);
frD = vertcat(out.frD);

bins2d = 0:10:250;
hfig = figure;
marginal_ax(1) = subplot(2,2,1);
MD = ML.movies_{1}
histogram(D.*MD.pixelSize_,bins2d,'Normalization','probability')
hold on; h2 = histogram(rD.*MD.pixelSize_,bins2d,'Normalization','probability');
ylabel('Freq');
main_ax = subplot(2,2,3);
histogram2(D*MD.pixelSize_,fD*MD.pixelSize_,bins2d,bins2d,'DisplayStyle','tile');
hold on;
plot(D*MD.pixelSize_,fD*MD.pixelSize_,'k.','MarkerSize',0.1);
xlim([0 bins2d(end)]);
ylim([0 bins2d(end)]);
xlabel('NPC - Lamin Distance (nm)');
ylabel('NPC - Face center Distance (nm)');
marginal_ax(2) = subplot(2,2,4);
histogram(fD.*MD.pixelSize_,bins2d,'Orientation','horizontal','Normalization','probability');
hold on; h2 = histogram(frD.*MD.pixelSize_,bins2d,'Orientation','horizontal','Normalization','probability');
xlabel('Freq');
deltay = marginal_ax(1).Position(4)-0.1;
deltax = marginal_ax(2).Position(3)-0.1;
marginal_ax(1).Position = marginal_ax(1).Position + [0 deltay deltax -deltay];
marginal_ax(2).Position = marginal_ax(2).Position + [deltax 0 -deltax deltay];
main_ax.Position = main_ax.Position +[0 0 deltax deltay];
saveas(hfig,'hist2d_npcs_to_lamins_and_faces.fig');
saveas(hfig,'hist2d_npcs_to_lamins_and_faces.png');
dots = findobj(hfig,'Type','Line');
dots.Visible = 'off';
saveas(hfig,'hist2d_npcs_to_lamins_and_faces_nodots.png');

hfig2 = figure;
marginal_ax(1) = subplot(2,2,1);
histogram(rD.*MD.pixelSize_,bins2d,'Normalization','probability','FaceColor',[0.8500 0.3250 0.0980]	);
ylabel('Freq');
main_ax = subplot(2,2,3);
histogram2(rD*MD.pixelSize_,frD*MD.pixelSize_,bins2d,bins2d,'DisplayStyle','tile')
xlabel('NPC - Lamin Distance (nm)');
ylabel('NPC - Face center Distance (nm)');
marginal_ax(2) = subplot(2,2,4);
histogram(frD.*MD.pixelSize_,bins2d,'Orientation','horizontal','Normalization','probability','FaceColor',[0.8500 0.3250 0.0980]	);
xlabel('Freq');
marginal_ax(1).Position = marginal_ax(1).Position + [0 deltay deltax -deltay];
marginal_ax(2).Position = marginal_ax(2).Position + [deltax 0 -deltax deltay];
main_ax.Position = main_ax.Position +[0 0 deltax deltay];
saveas(hfig,'hist2d_npcs_to_lamins_and_faces_rand.fig');
saveas(hfig,'hist2d_npcs_to_lamins_and_faces_rand.png');
