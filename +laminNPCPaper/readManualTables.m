function [ hfig ] = readManualTables( filename )
%readManualTables Read manual Excel table assessment

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
        cd('C:\Users\mak2714\Documents\UTSW\Paper\figures\bioinfo\manualAssessment');
        filename = 'manualAssessment_2020_01_29.xlsx';
    end
    [~,sheets] = xlsfinfo(filename);
    T = struct();
    getfields = @(template,varNames) varNames(~cellfun('isempty',regexp(varNames,['^' template])));
    for t=1:length(sheets)
        T.(sheets{t}) = readtable(filename,'Sheet',sheets{t});
        varNames = T.(sheets{t}).Properties.VariableNames;
        
        fields.SNR = getfields('SNR',varNames);
        fields.frame = getfields('frame',varNames);
        
        fields.SNR = fliplr(fields.SNR);
        fields.frame = fliplr(fields.frame);
        
        subTables.(sheets{t}) = T.(sheets{t})(1:10,fields.frame);
        subTables.(sheets{t}).Properties.VariableNames = fields.SNR;
        meanTables.(sheets{t}) = varfun(@mean,subTables.(sheets{t}));
        stdTables.(sheets{t}) = varfun(@std,subTables.(sheets{t}));
        
        factor = 64/180;
        
        hfig = figure;
        bar(meanTables.(sheets{t}).Variables.*factor);
        hold on;
        errorbar(meanTables.(sheets{t}).Variables.*factor, ...
                 stdTables.(sheets{t}).Variables.*factor, ...
                 'k','LineStyle','none');
        xticklabels(fields.SNR);
        title(sheets{t});
        ylabel('Gap Length (px)');
        saveas(hfig,[sheets{t} '_bar.fig']);
        saveas(hfig,[sheets{t} '_bar.pdf']);
        
        hfig = figure;
        boxplot(subTables.(sheets{t}).Variables.*factor,fields.SNR, ...
            'PlotStyle','compact','Jitter',0, ...
            'LabelOrientation','horizontal');
        grid on;
        title(sheets{t});
        ylabel('Gap Length (px)');
        saveas(hfig,[sheets{t} '_box.fig']);
        saveas(hfig,[sheets{t} '_box.pdf']);
    end
    
    
    
    

%     keyboard;
end

