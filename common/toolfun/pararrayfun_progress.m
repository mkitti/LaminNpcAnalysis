function [ varargout ] = pararrayfun_progress( func, varargin )
%pararrayfun_progress Run arrayfun in parallel with progress meter

% Find where the parameters begin
arraySize = size(varargin{1});
for paramIdx=1:length(varargin)
    inSize = size(varargin{paramIdx});
    if(~all(inSize == arraySize))
        break;
    end
end
if(mod(length(varargin)-paramIdx,2)==0 ...
    && paramIdx > 1 ...
    && ischar(varargin{paramIdx-1}))
    % Remaining arguments for parameters is an odd number.
    % Previous argument could be a parameter name that
    %    happens to be the same size as other array input
    paramIdx = paramIdx - 1;
elseif(paramIdx == length(varargin))
    paramIdx = paramIdx + 1;
else
end

% Just convert arrays to cells for now and use parcellfun_progress
arrays = cellfun(@num2cell,varargin(1:paramIdx-1),'UniformOutput',false);

[varargout{1:nargout}] = parcellfun_progress(func, arrays{:}, varargin{paramIdx:end});

end
