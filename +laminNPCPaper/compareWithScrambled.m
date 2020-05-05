function [ out_median, out_median_diff, out_p_values, out_p_values_matched ] = compareWithScrambled( in_struct )
%compareWithScrambled Compare with scrambled data

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

