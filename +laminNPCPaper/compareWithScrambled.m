function [ out_median, out_median_diff, out_p_values, out_p_values_matched ] = compareWithScrambled( in_struct )
%compareWithScrambled Compare with scrambled data
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
fields = fieldnames(in_struct);

is_scrambled = strcmp(fields,'scrambled');
assert(sum(is_scrambled) == 1);

scrambled_median = median(in_struct.scrambled);
scrambled_std = std(in_struct.scrambled);

for i=1:length(fields)
    out_median.(fields{i}) = median(in_struct.(fields{i}));
    out_std.(fields{i}) = std(in_struct.(fields{i}));
    
    combined_field = [fields{i} '_minus_scrambled'];
    out_median_diff.(combined_field) = out_median.(fields{i}) - scrambled_median;
    out_std_diff.(combined_field) = out_std.(fields{i}) - scrambled_std;
    
    combined_field = [fields{i} '_vs_scrambled'];
    out_p_values.(combined_field) = ranksum(in_struct.(fields{i}),in_struct.scrambled);
    out_p_values_matched.(combined_field) = mean(laminNPCPaper.ranksum_matched_n(in_struct.(fields{i}),in_struct.scrambled));
end

if(nargout == 1)
    out.median = out_median;
    out.std = out_std;
    out.median_diff = out_median_diff;
    out.std_diff = out_std_diff;
    out.p_values = out_p_values;
    out.p_values_matched = out_p_values_matched;
    
    out_median = out;
end


end

