function [ tf ] = insequence_and_scalar( x, start, stop , interval)
%insequence Checks to see if value is in the sequence start:interval:stop
%
% Roughly equivalent to isscalar(x) && ismember(x,start:interval:stop)
%
% This function does not handle negative intervals
% It is faster than ismember since for a sequence one can first check to
% see if x in the interval [start stop], and then see if (x-start)/interval
% is an integer.
%
% INPUT
% x - vector to query if in the sequence
% start - beginning of sequence
% stop  - end of sequence
% interval - (optional) interval between numbers in sequence
%            default: 1
%
% OUTPUT
% tf - logical vector same size as x
%
% See also ismember

% Mark Kittisopikul, April 2017
% Jaqaman Lab
% UT Southwestern

if(isscalar(x))

    if(x < start || x > stop)
        tf = false;
        return;
    end

    if(nargin < 4)
        x = (x - start);

    else
        x = (x - start)./interval;
    end
    tf = x == round(x);

else
    
    tf = false;
    return;
       
end

end

