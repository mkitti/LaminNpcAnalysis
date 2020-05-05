function [ out_median, out_median_diff, out_p_values, out_p_values_matched, out_p_values_dispersion, out_p_values_dispersion_matched ] = calc_median_and_p_values( in_struct )
%calc_median_and_p_values Calculate median and p-values using ranksum
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

%% Calculate p-values
fields = fieldnames(in_struct);
for f = 1:2:length(fields)
    combined_field = [fields{f} '_vs_' fields{f+1}];
    out_p_values.(combined_field) =  ranksum(in_struct.(fields{f}),in_struct.(fields{f+1}));
    if(out_p_values.(combined_field) >= 0.05)
        [~,out_p_values_dispersion.(combined_field)] = ansaribradley(in_struct.(fields{f}),in_struct.(fields{f+1}));
    else
        out_p_values_dispersion.(combined_field) = NaN;
    end
end

%% Calculate p-values matched
fields = fieldnames(in_struct);
for f = 1:2:length(fields)
    combined_field = [fields{f} '_vs_' fields{f+1}];
    out_p_values_matched.(combined_field) =  mean(laminNPCPaper.ranksum_matched_n(in_struct.(fields{f}),in_struct.(fields{f+1}) ));
end

%% Calculate median
fields = fieldnames(in_struct);
for f = 1:2:length(fields)
    combined_field = [fields{f} '_minus_' fields{f+1}];
    out_median.(fields{f}) = median(in_struct.(fields{f}));
    out_median.(fields{f+1}) = median(in_struct.(fields{f+1}));
    out_std.(fields{f}) = std(in_struct.(fields{f}));
    out_std.(fields{f+1}) = std(in_struct.(fields{f+1}));
    out_median_diff.(combined_field) =  out_median.(fields{f})-out_median.(fields{f+1});
    out_std_diff.(combined_field) = out_std.(fields{f})-out_std.(fields{f+1});
    
    out_n.(fields{f}) = length(in_struct.(fields{f}));
    out_n.(fields{f+1}) = length(in_struct.(fields{f+1}));
end

if(nargout == 1)
    out.median = out_median;
    out.median_diff = out_median_diff;
    out.std = out_std;
    out.std_diff = out_std_diff;
    out.p_values = out_p_values;
    out.p_values_matched = out_p_values_matched;
    out.p_values_dispersion = out_p_values_dispersion;
%     out.p_values_dispersion_matched = out_p_values_dispersion_matched;
    out.n = out_n;
    
    out_median = out;
end

end

