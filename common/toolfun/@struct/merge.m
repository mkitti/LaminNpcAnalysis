function [ S ] = merge( varargin )
%struct.merge Merges struct arrays together
%
% If there are repeated fields, the values in the earlier struct arrays
% take precedence.

fields = cellfun(@fieldnames,varargin,'UniformOutput',false);
values = cellfun(@struct2cell,varargin,'UniformOutput',false);

fields = vertcat(fields{:});
values = vertcat(values{:});

try
    S = cell2struct(values,fields);
catch exception
    switch(exception.identifier)
        case 'MATLAB:DuplicateFieldName'
            [fields, ia] = unique(fields);
            values = values(ia,:);
            values = reshape(values,[length(ia) size(varargin{1})]);
            S = cell2struct(values,fields);
        otherwise
            throw(exception)
    end
end


end

