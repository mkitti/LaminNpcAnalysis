function [ out ] = plot_knockdown_histograms( in )
%plot_knockdown_histograms Plot knockdown histograms for each field in
%struct
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
name = inputname(1); 
fields = fieldnames(in);

for f=1:length(fields)
%     lamins.functions.plot_histogram_2d(in.(fields{f}),'saveFigs',[name '_' fields{f}]); 
    [s.hfig,s.hfig2,s.hfig3,s.hfig4] = lamins.functions.plot_histogram_2d(in.(fields{f}),'name',[name '_' fields{f}]); 
    out.(fields{f}) = s;
end

    fig_array = struct2array(struct2array(out));
    fig_array = reshape(fig_array,4,4);
    
    set(fig_array,'Units','normalized');

    w = fig_array(1).Position(3);
    h = fig_array(1).Position(4);
    
    for i=1:4
        for j=1:4
            fig_array(i,j).Position(1) = (i-1)*w;
            fig_array(i,j).Position(2) = (1-h)-(j-1)*h;
        end
    end

    twoViolinPlots = [fig_array(1,:).UserData];


    observedPlots = [fig_array(2,:).UserData];

    expectedPlots = [fig_array(3,:).UserData];

    diffPlots = [fig_array(4,:).UserData];

%     histograms = [twoViolinPlots.histogram observedPlots.histogram ];
%     ax = [histograms.Parent];
%     lims = vertcat(ax.CLim);
%     [ax.CLim] = deal([min(lims(:,1)) max(lims(:,2))]);
% 
%     histograms = [expectedPlots.histogram];
%     ax = [histograms.Parent];
%     lims = vertcat(ax.CLim);
%     [ax.CLim] = deal([min(lims(:,1)) max(lims(:,2))]);

    ax = [observedPlots.marginal_face_plot expectedPlots.marginal_face_plot];
    ax = [ax.ScatterPlot];
    ax = unique([ax.Parent]);
    lims = vertcat(ax.XLim);
    [ax.XLim] = deal([min(lims(:,1)) max(lims(:,2))]);

    ax = [observedPlots.marginal_fiber_plot expectedPlots.marginal_fiber_plot];
    ax = [ax.ScatterPlot];
    ax = unique([ax.Parent]);
    lims = vertcat(ax.XLim);
    [ax.XLim] = deal([min(lims(:,1)) max(lims(:,2))]);


    ax = [diffPlots.histogram];
    lims = vertcat(ax.CLim);
    [ax.CLim] = deal([min(lims(:,1)) max(lims(:,2))]);

    ax = [diffPlots.colorbar];
    [ax.Limits] = deal([min(lims(:,1)) max(lims(:,2))]);

    ax = [diffPlots.marginal_face_plot];
    lims = vertcat(ax.XLim);
    [ax.XLim] = deal([min(lims(:,1)) max(lims(:,2))]);

    ax = [diffPlots.marginal_fiber_plot];
    lims = vertcat(ax.YLim);
    [ax.YLim] = deal([min(lims(:,1)) max(lims(:,2))]);

    for f = fig_array(:).'
        saveas(f,[f.Name '.pdf']); saveas(f,[f.Name '.fig']);
    end

end

