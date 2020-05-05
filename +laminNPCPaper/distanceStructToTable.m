function [ out ] = distanceStructToTable( s, prefix)
%distanceStructToTable Convert distance struct to tabular form

if(nargin < 2)
    prefix = false;
end

sa = struct2array(s.std);
ma = struct2array(s.median);
mad = struct2array(s.median_diff);
sad = struct2array(s.std_diff);
pma = struct2array(s.p_values);
psa = struct2array(s.p_values_dispersion);
n = struct2array(s.n);

data = [ma(1:2:end); sa(1:2:end); ma(2:2:end); sa(2:2:end); mad; sad; pma; psa];


if(isfield(s,'vs_scrambled'))
    mad_vs_scramble = struct2array(s.vs_scrambled.median_diff);
    pma_vs_scramble = struct2array(s.vs_scrambled.p_values);

    data = [data; mad_vs_scramble(1:2:end); pma_vs_scramble(1:2:end)];
end

data = [data; n(1:2:end)];

data = data.';





rownames = fields(s.median);
rownames = rownames(1:2:end);

colnames = { ...
    'Obs_Median_nm', ...
    'Obs_Std_nm', ...
    'Exp_Median_nm', ...
    'Exp_Std_nm', ...
    'Dif_Median_nm', ...
    'Dif_Std_nm', ...
    'Pval_Median', ...
    'Pval_Std' ...
    };

if(isfield(s,'vs_scrambled'))
    colnames = [colnames {'Dif_Median_Scramble_nm'} {'Pval_Median_Scramble'}];
end

colnames = [colnames {'N_npc'}];

if(islogical(prefix) && prefix)
    prefix = inputname(1);
end

if(ischar(prefix))
    rownames = strcat(prefix,'_',rownames);
end

out = array2table(data,'RowNames',rownames,'VariableNames',colnames);

end

