function S = regexpfields(S,varargin)
% regexpfields produces a struct with a subset of the fields matched by the
% regular expressions
    
    % combine the regular expressions together into a single expression
    filter = ['(' strjoin(varargin,')|(') ')'];
    
    % extract the current fields and values
    fields  = fieldnames(S);
    values = struct2cell(S);
    
    % build a binary filter based on the expression
    startIdx = regexp(fields,filter,'once');
    filter = ~cellfun('isempty',startIdx);
    
    % apply the filter
    fields = fields(filter);
    values = values(filter);
    
    % combine values and fields to create the filtered struct
    S = cell2struct(values,fields);
end