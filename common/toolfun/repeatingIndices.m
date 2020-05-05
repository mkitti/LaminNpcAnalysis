function [r,n]=repeatingIndices(v)
% repeatingIndices returns the repeating values in a vector of sequential entries
%
% repeatingIndices may be used after FIND to extract those row or columns
% indices which are listed more than once.
%
% SYNOPSIS [r,n]=repeatingIndices(v)
%
% INPUT    v : vector of entries to be checked
%
% OUTPUT   r : vector of indices of repeating entries 
%          n : vector of indices of entries listed only once
%
% Aaron Ponti, March 14th, 2003

% Initialize index vectors
n=[];
r=[];

% Find repeating entries
n0=1; r0=1;
for c1=1:max(v)
    % Find position(s)
    pos=find(v==c1);
    lPos=length(pos);
    % If the entry appears only once, list it
    if lPos==1
        n(n0)=pos;
        n0=n0+1;
    else
        r(r0:r0+lPos-1)=pos;
        r0=r0+lPos;
    end
end
