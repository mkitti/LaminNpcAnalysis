function params = prepPerChannelParams(params,nChan)
%PREPPERCHANNELPARAMS sets up per-channel parameter structure given variable input format
%
% params = prepPerChannelParams(params,nChan)
%
% This is for functions which have parameters which may vary for each
% channel in a dataset, or which may also be constant across channels. 
%
% It expects the input structure to have a field "PerChannelParams" which
% is a cell array of field names, and replictes them if necessary so that
% all fields with these names have exactly nChan columns (or elements if a
% cell array).
%

%Hunter Elliott
%2013

if isfield(params,'PerChannelParams') && ~isempty(params.PerChannelParams) && iscell(params.PerChannelParams);
      
    nPCPar = numel(params.PerChannelParams);
    
    for j = 1:nPCPar        
        if isfield(params,params.PerChannelParams{j})
            %nEl = numel(params.(params.PerChannelParams{j}));
            if ischar(params.(params.PerChannelParams{j})) 
                params.(params.PerChannelParams{j}) = {params.(params.PerChannelParams{j})};
            end
            nEl = size(params.(params.PerChannelParams{j}),2);
            if  nEl == 1
                params.(params.PerChannelParams{j}) = repmat(params.(params.PerChannelParams{j}),[1 nChan]);
            elseif nEl ~= nChan
                try
                    warning(['The parameter "' params.PerChannelParams{j} '" was designated as a per-channel parameter, but contained ' num2str(nEl) ' elements - this must be specified as either a scalar or have array of size equal to the number of channels!'])
                    params.(params.PerChannelParams{j}) = repmat({params.(params.PerChannelParams{j})},[1 nChan]);
                catch
                    error(['The parameter "' params.PerChannelParams{j} '" was designated as a per-channel parameter, but contained ' num2str(nEl) ' elements - this must be specified as either a scalar or have array of size equal to the number of channels!'])    
                end
            end                                    
        end
    end        
end
