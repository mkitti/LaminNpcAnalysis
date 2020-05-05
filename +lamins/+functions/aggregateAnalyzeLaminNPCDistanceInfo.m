function [ varargout ] = aggregateAnalyzeLaminNPCDistanceInfo( filter )
%aggregateAnalyzeLaminNPCDistanceInfo Aggregate data from
%analyzeLaminNPCDistance
%
% INPUT
% filter - string to be used to select directories for aggregation, see
% regexp
%
% OUTPUT
% s - a struct with fields
%  .xdata -
%  .ydata - 

folder = 'analyzeLaminsNPCDistance_2018_05_09';
folder = 'analyzeLaminsNPCDistance';


    if(ischar(filter))
        D = dir;
        D = D([D.isdir]);
        D = D(~cellfun(@(x) isempty(regexp(x,filter, 'once')),{D.name}));
        dirs = {D.name};
    elseif(isa(filter,'MovieList'))
        ML = filter;
        ML.sanityCheck;
        D = ML.movies_;
        dirs = cellfun(@(x) x.movieDataPath_,ML.movies_,'UniformOutput',false);
    end
    hfig = cell(1,length(D));
    xdata = cell(1,length(D));
    ydata = cell(1,length(D));
    % Uniform distribution data
    udata = cell(1,length(D));
    % Actual distribution data
    adata = cell(1,length(D));
    area = zeros(1,length(D));
    for i=1:length(D)
        hfig{i} = openfig([dirs{i} filesep folder filesep 'NPC-Lamin_Distance_DifferenceFromRandom.fig'],'invisible');
        xdata{i} = hfig{i}.Children.Children.XData;
        ydata{i} = hfig{i}.Children.Children.YData;
        close(hfig{i});
        hfig2{i} = openfig([dirs{i} filesep folder filesep 'NPC-Lamin_Distance_Pair_Histogram.fig'],'invisible');
        udata{i} = hfig2{i}.Children.Children(1).Data;
        adata{i} = hfig2{i}.Children.Children(2).Data;
        close(hfig2{i});
        dataFile = [dirs{i} filesep folder filesep 'analyzeLaminsNPCdistance.mat'];
        if(exist(dataFile,'file'))
            data = load(dataFile);
            area(i) = sum(data.mask(:));
        end
    end
    [maxX,maxXidx] = max(cellfun('prodofsize',ydata));
    for i=1:length(D)
        ydata{i}(end:maxX) = NaN;
    end
    Y = vertcat(ydata{:});
    figs.diff = figure;
    errorbar(xdata{maxXidx},mean(Y,1),std(Y,0,1)/sqrt(length(D)));
    ylabel('Frequency Difference from Random');
    xlabel('Distance from center of lamin fiber (nm)');
    figs.violin = figure;
    figs.violinplots = violinplot(struct('Uniform',vertcat(udata{:}),'Actual',vertcat(adata{:})),[],'ShowData',false,'ShowNotches',true);
    ylim([0 200]);
    ylabel('Distance from center of lamin fiber (nm)');
    grid on;
    
    if(nargout > 1)
        varargout{1} = figs;
        varargout{2} = xdata{maxXidx};
        varargout{3} = Y;
        varargout{4} = udata;
        varargout{5} = adata;
    else
        s.xdata = xdata{maxXidx};
        s.ydata = Y;
        s.udata = udata;
        s.adata = adata;
        s.udata_all = vertcat(udata{:});
        s.adata_all = vertcat(adata{:});
        s.figs = figs;
        s.area = area;
        varargout{1} = s;
    end

end

