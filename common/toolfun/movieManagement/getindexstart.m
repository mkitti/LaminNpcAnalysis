function [starti, startsw] = getindexstart(filename)
% % generate a-z string
for n = 1:26
    strr{n} = char(n -1 + 'a');
end
% generate 0-9 string
for n = 1:10
    stnum{n} = num2str(n-1);
end
index_char = regexp(filename, strr, 'ignorecase');
startsw = []; starti = [];
for i = 1:length(index_char) %it does not check the 'tif'
    if ~isempty(index_char{i})
        while ~isempty(index_char{i})
            if index_char{i}(1)+3<length(filename)
                if sum(strcmp(stnum, filename(index_char{i}(1)+1))) == 0
                    index_char{i}(1) = [];
                elseif sum(strcmp(stnum, filename(index_char{i}(1)+2))) > 0 ...
                        && sum(strcmp(stnum, filename(index_char{i}(1)+3))) == 0 ...
                        && isempty(starti)...
                        && strcmp('_', filename(index_char{i}(1)-1))
                    starti = index_char{i}(1);
                elseif sum(strcmp({'s', 'w', 'S', 'W'}, filename(index_char{i}(1)))) > 0 ...
                        && sum(strcmp(stnum, filename(index_char{i}(1)+1))) > 0
                    startsw = [startsw index_char{i}(1)];
                    break;
                else
                    index_char{i}(1) = [];
                end
            else
                index_char{i}(1) = [];
            end
        end
    end
end
