% NPC-Lamin Distance Paper

%% Load LA wt data
cd('R:\Basic_Sciences\CDB\GoldmanLab\Takeshi\N-SIM\040915\MEFWTLAmAb414-005_Reconstructed\analyzeLaminsNPCDistance_2018_05_09');
MD = MovieData.load('..\MEFWTLAmAb414-005_Reconstructed.mat');
wtladata = load('analyzeLaminsNPCdistance.mat');

%% Pack Data

clear laminNPCData
clear faceNPCData

laminNPCData.wt = wtladata.D*MD.pixelSize_;
laminNPCData.wtRand = wtladata.rD*MD.pixelSize_;

faceNPCData.wt = wtladata.fD*MD.pixelSize_;
faceNPCData.wtRand = wtladata.frD*MD.pixelSize_;

%% Load LB1-null data
cd('R:\Basic_Sciences\CDB\GoldmanLab\Takeshi\N-SIM\041015\MEFLB1-LAmAb414-006_Reconstructed\analyzeLaminsNPCDistance_2018_05_09');
MD = MovieData.load('..\MEFLB1-LAmAb414-006_Reconstructed.mat');
lb1nulldata = load('analyzeLaminsNPCdistance.mat');

%% Pack Data

laminNPCData.lb1null = lb1nulldata.D*MD.pixelSize_;
laminNPCData.lb1nullRand = lb1nulldata.rD*MD.pixelSize_;

faceNPCData.lb1null = lb1nulldata.fD*MD.pixelSize_;
faceNPCData.lb1nullRand = lb1nulldata.frD*MD.pixelSize_;

%% Figure 2C

hfig = figure;
hfig.Position(1:2) = hfig.Position(1:2) + hfig.Position(3:4) - 650;
hfig.Position(3:4) = 650;
subplot(2,2,1);
h = lamins.functions.plot_positive_violin_pairs(laminNPCData,false);
grid on;
ylabel('NPC to Lamin A Fiber Distance');
% hfig.Position = [1.0003e+03 1.0397e+03 500 300];
ylim([0 600]);
view(90,90);
xticklabels({'wt','Lmnb1-/-'});


% figure;
subplot(2,2,3);
lamins.functions.plot_violin_diff(h,50);

% Figure 2D

% hfig = figure;
subplot(2,2,2);
h = lamins.functions.plot_positive_violin_pairs(faceNPCData,false);
grid on;
ylabel('NPC to LA Face Center Distance');
xticklabels({'wt','Lmnb1-/-'});
% hfig.Position = [1.0003e+03 1.0397e+03 500 300];
% ylim([0 600]);

% figure;
subplot(2,2,4);
lamins.functions.plot_violin_diff(h,200);

%% Figure S2A

lamins.functions.plot_histogram_2d(wtladata,'pixelSize',MD.pixelSize_);

%% Figure S2B

lamins.functions.plot_histogram_2d(lb1nulldata,'pixelSize',MD.pixelSize_);
